import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { transaction_id, product_id, user_id, signed_payload } = await req.json();

    if (!transaction_id || !product_id || !user_id) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: transaction_id, product_id, user_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Placeholder: verify the signed_payload with Apple's App Store Server API
    const isValid = await verifyAppleTransaction(signed_payload);
    if (!isValid) {
      return new Response(
        JSON.stringify({ error: "Transaction verification failed" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: purchase, error: purchaseError } = await supabase
      .from("purchases")
      .insert({
        user_id,
        product_id,
        transaction_id,
        status: "completed",
      })
      .select()
      .single();

    if (purchaseError) {
      throw new Error(`Purchase insert failed: ${purchaseError.message}`);
    }

    const expiresAt = computeExpiration(product_id);

    const { data: entitlement, error: entitlementError } = await supabase
      .from("entitlements")
      .upsert(
        {
          user_id,
          product_id,
          status: "active",
          expires_at: expiresAt,
          granted_at: new Date().toISOString(),
          source: "apple_iap",
        },
        { onConflict: "user_id,product_id", ignoreDuplicates: false }
      )
      .select()
      .single();

    if (entitlementError) {
      throw new Error(`Entitlement upsert failed: ${entitlementError.message}`);
    }

    return new Response(
      JSON.stringify({ purchase, entitlement }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

async function verifyAppleTransaction(_signedPayload: string): Promise<boolean> {
  // TODO: Implement actual Apple App Store Server API verification
  // https://developer.apple.com/documentation/appstoreserverapi
  // For now, accept all transactions in development
  return true;
}

function computeExpiration(productId: string): string {
  const now = new Date();
  if (productId === "premium_yearly") {
    now.setFullYear(now.getFullYear() + 1);
  } else {
    now.setMonth(now.getMonth() + 1);
  }
  return now.toISOString();
}

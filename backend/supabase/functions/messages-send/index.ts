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
    const { sender_id, recipient_id, content } = await req.json();

    if (!sender_id || !recipient_id || !content) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: sender_id, recipient_id, content" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (content.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: "Message content cannot be empty" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: recipient, error: recipientError } = await supabase
      .from("users")
      .select("id")
      .eq("id", recipient_id)
      .single();

    if (recipientError || !recipient) {
      return new Response(
        JSON.stringify({ error: "Recipient not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: message, error: insertError } = await supabase
      .from("messages")
      .insert({
        sender_id,
        recipient_id,
        content: content.trim(),
      })
      .select()
      .single();

    if (insertError) {
      throw new Error(`Message insert failed: ${insertError.message}`);
    }

    return new Response(
      JSON.stringify({ message }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

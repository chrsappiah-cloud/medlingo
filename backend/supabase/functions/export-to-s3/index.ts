import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { S3Client, PutObjectCommand } from "https://esm.sh/@aws-sdk/client-s3@3.400.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const TABLES_TO_EXPORT = [
  "users",
  "learner_profiles",
  "chapters",
  "lessons",
  "exercises",
  "attempts",
  "purchases",
  "entitlements",
];

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const s3 = new S3Client({
      region: Deno.env.get("AWS_REGION") ?? "us-east-1",
      credentials: {
        accessKeyId: Deno.env.get("AWS_ACCESS_KEY_ID")!,
        secretAccessKey: Deno.env.get("AWS_SECRET_ACCESS_KEY")!,
      },
    });

    const bucket = Deno.env.get("S3_EXPORT_BUCKET");
    if (!bucket) {
      throw new Error("S3_EXPORT_BUCKET environment variable not set");
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const exportResults: Record<string, { rows: number; key: string }> = {};

    for (const table of TABLES_TO_EXPORT) {
      const { data, error } = await supabase.from(table).select("*");

      if (error) {
        console.error(`Failed to export ${table}: ${error.message}`);
        continue;
      }

      const key = `exports/${timestamp}/${table}.json`;
      const body = JSON.stringify(data, null, 2);

      await s3.send(
        new PutObjectCommand({
          Bucket: bucket,
          Key: key,
          Body: body,
          ContentType: "application/json",
        })
      );

      exportResults[table] = { rows: data?.length ?? 0, key };
    }

    const { error: auditError } = await supabase.from("audit_logs").insert({
      action: "data_export",
      target_type: "s3",
      metadata: {
        bucket,
        timestamp,
        tables: exportResults,
        total_tables: Object.keys(exportResults).length,
      },
    });

    if (auditError) {
      console.error(`Audit log insert failed: ${auditError.message}`);
    }

    return new Response(
      JSON.stringify({
        success: true,
        timestamp,
        exported_tables: exportResults,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const s3 = new S3Client({ region: process.env.AWS_REGION || "us-east-1" });
const BUCKET = process.env.BACKUP_BUCKET || "medlingo-backups";

interface BackupEvent {
  tables: string[];
  supabaseUrl: string;
  supabaseServiceKey: string;
}

export const handler = async (event: BackupEvent) => {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const results: { table: string; status: string; key?: string; error?: string }[] = [];

  for (const table of event.tables) {
    try {
      const response = await fetch(
        `${event.supabaseUrl}/rest/v1/${table}?select=*`,
        {
          headers: {
            apikey: event.supabaseServiceKey,
            Authorization: `Bearer ${event.supabaseServiceKey}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${await response.text()}`);
      }

      const data = await response.json();
      const key = `backups/${timestamp}/${table}.json`;

      await s3.send(
        new PutObjectCommand({
          Bucket: BUCKET,
          Key: key,
          Body: JSON.stringify(data, null, 2),
          ContentType: "application/json",
          ServerSideEncryption: "AES256",
        })
      );

      results.push({ table, status: "success", key });
    } catch (error: any) {
      results.push({ table, status: "error", error: error.message });
    }
  }

  const summary = {
    timestamp,
    totalTables: event.tables.length,
    successful: results.filter((r) => r.status === "success").length,
    failed: results.filter((r) => r.status === "error").length,
    results,
  };

  // Store the manifest
  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: `backups/${timestamp}/manifest.json`,
      Body: JSON.stringify(summary, null, 2),
      ContentType: "application/json",
    })
  );

  return summary;
};

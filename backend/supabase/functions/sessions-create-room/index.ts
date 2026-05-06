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
    const { session_id } = await req.json();

    if (!session_id) {
      return new Response(
        JSON.stringify({ error: "Missing required field: session_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: session, error: sessionError } = await supabase
      .from("sessions")
      .select("*")
      .eq("id", session_id)
      .single();

    if (sessionError || !session) {
      return new Response(
        JSON.stringify({ error: "Session not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const dailyApiKey = Deno.env.get("DAILY_API_KEY");
    if (!dailyApiKey) {
      throw new Error("DAILY_API_KEY environment variable not set");
    }

    const roomName = `medlingo-session-${session_id}`;
    const expiresAt = new Date(
      new Date(session.starts_at).getTime() + session.duration_minutes * 60 * 1000 + 15 * 60 * 1000
    );

    const roomResponse = await fetch("https://api.daily.co/v1/rooms", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${dailyApiKey}`,
      },
      body: JSON.stringify({
        name: roomName,
        properties: {
          exp: Math.floor(expiresAt.getTime() / 1000),
          max_participants: session.seats_available + 1,
          enable_chat: true,
          enable_screenshare: true,
        },
      }),
    });

    if (!roomResponse.ok) {
      const errBody = await roomResponse.text();
      throw new Error(`Daily.co room creation failed: ${errBody}`);
    }

    const room = await roomResponse.json();

    const tokenResponse = await fetch("https://api.daily.co/v1/meeting-tokens", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${dailyApiKey}`,
      },
      body: JSON.stringify({
        properties: {
          room_name: roomName,
          exp: Math.floor(expiresAt.getTime() / 1000),
          is_owner: true,
        },
      }),
    });

    if (!tokenResponse.ok) {
      const errBody = await tokenResponse.text();
      throw new Error(`Daily.co token creation failed: ${errBody}`);
    }

    const tokenData = await tokenResponse.json();

    return new Response(
      JSON.stringify({
        room_url: room.url,
        token: tokenData.token,
        expires_at: expiresAt.toISOString(),
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

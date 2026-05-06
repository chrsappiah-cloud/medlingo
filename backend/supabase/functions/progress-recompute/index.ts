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
    const { user_id, chapter_id } = await req.json();

    if (!user_id || !chapter_id) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: user_id, chapter_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: attempts, error: attemptsError } = await supabase
      .from("attempts")
      .select("id, score, total_questions, correct_answers, completed_at")
      .eq("learner_id", user_id)
      .eq("chapter_id", chapter_id)
      .not("completed_at", "is", null)
      .order("completed_at", { ascending: false });

    if (attemptsError) {
      throw new Error(`Failed to fetch attempts: ${attemptsError.message}`);
    }

    const { data: exercises, error: exercisesError } = await supabase
      .from("exercises")
      .select("id, xp_reward")
      .eq("chapter_id", chapter_id);

    if (exercisesError) {
      throw new Error(`Failed to fetch exercises: ${exercisesError.message}`);
    }

    const totalExercises = exercises?.length ?? 0;
    const completedAttempts = attempts ?? [];
    const uniqueExercisesAttempted = new Set(completedAttempts.map((a) => a.id)).size;

    let totalCorrect = 0;
    let totalQuestions = 0;
    for (const attempt of completedAttempts) {
      totalCorrect += attempt.correct_answers ?? 0;
      totalQuestions += attempt.total_questions ?? 0;
    }

    const accuracy = totalQuestions > 0 ? totalCorrect / totalQuestions : 0;
    const coverage = totalExercises > 0 ? uniqueExercisesAttempted / totalExercises : 0;

    // Mastery = weighted combination of accuracy (70%) and coverage (30%)
    const masteryScore = Math.round((accuracy * 0.7 + coverage * 0.3) * 100);

    const totalXpEarned = completedAttempts.reduce((sum, a) => {
      const ratio = a.total_questions > 0 ? (a.correct_answers / a.total_questions) : 0;
      return sum + Math.round(ratio * 10);
    }, 0);

    const progress = {
      user_id,
      chapter_id,
      mastery_score: masteryScore,
      accuracy: Math.round(accuracy * 100),
      coverage: Math.round(coverage * 100),
      total_attempts: completedAttempts.length,
      total_xp_earned: totalXpEarned,
      last_attempt_at: completedAttempts.length > 0 ? completedAttempts[0].completed_at : null,
    };

    return new Response(
      JSON.stringify({ progress }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

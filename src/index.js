export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // --------------------------------------------------
    // HEALTH CHECK
    // --------------------------------------------------
    if (url.pathname === "/api/health") {
      return json({
        ok: true,
        service: "hellboxcomics",
        storage: {
          public: !!env.PUBLIC_BUCKET,
          private: !!env.PRIVATE_BUCKET,
        },
      });
    }

    // --------------------------------------------------
    // FALL BACK TO STATIC WEBSITE
    // --------------------------------------------------
    return env.ASSETS.fetch(request);
  },
};


function json(data, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

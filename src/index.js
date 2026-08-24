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
    // ASHBOX #001
    // --------------------------------------------------
    if (url.pathname === "/api/comics/ashbox/001") {
      const object = await env.PUBLIC_BUCKET.get(
        "comics/ashbox/001/metadata/web/issue.json"
      );

      if (!object) {
        return json(
          {
            ok: false,
            error: "Issue metadata not found",
          },
          404
        );
      }

      const data = await object.json();

      return json(data, 200, {
        "Cache-Control": "public, max-age=300",
      });
    }

    // --------------------------------------------------
    // FALL BACK TO STATIC WEBSITE
    // --------------------------------------------------
    return env.ASSETS.fetch(request);
  },
};


function json(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...extraHeaders,
    },
  });
}

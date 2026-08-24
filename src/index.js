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
    // PUBLIC R2 TEST
    // --------------------------------------------------
    if (url.pathname === "/api/storage/public-test") {
      const key = "system/hellbox-test.txt";

      await env.PUBLIC_BUCKET.put(
        key,
        "Hellbox Comics R2 public storage is working."
      );

      return json({
        ok: true,
        bucket: "hellbox-public",
        key,
      });
    }

    // --------------------------------------------------
    // PUBLIC R2 READ TEST
    // --------------------------------------------------
    if (url.pathname === "/api/storage/public-test/read") {
      const key = "system/hellbox-test.txt";

      const object = await env.PUBLIC_BUCKET.get(key);

      if (!object) {
        return json(
          {
            ok: false,
            error: "Test object not found.",
          },
          404
        );
      }

      return new Response(object.body, {
        headers: {
          "Content-Type": "text/plain; charset=utf-8",
        },
      });
    }

    // --------------------------------------------------
    // PRIVATE R2 TEST
    // --------------------------------------------------
    if (url.pathname === "/api/storage/private-test") {
      const key = "system/hellbox-private-test.txt";

      await env.PRIVATE_BUCKET.put(
        key,
        "Hellbox Comics private storage is working."
      );

      return json({
        ok: true,
        bucket: "hellbox-private",
        key,
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

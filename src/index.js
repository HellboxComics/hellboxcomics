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
    // PUBLIC R2 FILES
    // Example:
    // /api/public/comics/ashbox/001/metadata/...
    // --------------------------------------------------
    if (url.pathname.startsWith("/api/public/")) {
      const key = url.pathname.replace("/api/public/", "");

      if (!key) {
        return json({ error: "Missing object path" }, 400);
      }

      const object = await env.PUBLIC_BUCKET.get(key);

      if (!object) {
        return json({ error: "File not found" }, 404);
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("ETag", object.httpEtag);

      return new Response(object.body, {
        headers,
      });
    }

    // --------------------------------------------------
    // PRIVATE R2 FILES
    // --------------------------------------------------
    if (url.pathname.startsWith("/api/private/")) {
      const key = url.pathname.replace("/api/private/", "");

      if (!key) {
        return json({ error: "Missing object path" }, 400);
      }

      const object = await env.PRIVATE_BUCKET.get(key);

      if (!object) {
        return json({ error: "File not found" }, 404);
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("ETag", object.httpEtag);

      return new Response(object.body, {
        headers,
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

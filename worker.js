// Cloudflare Worker entry point. Serves the static site in ./public via the Static Assets binding.
// (A static-assets-only Worker can omit this, but a real entry point is the most compatible with the
//  git-connected Workers Builds flow.)
export default {
  async fetch(request, env) {
    return env.ASSETS.fetch(request);
  }
};

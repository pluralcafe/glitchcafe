import base_english from 'flavours/glitch/locales/en';
import inherited from 'mastodon/locales/en-cafe.json';

const messages = {
  'getting_started.open_source_notice': 'GlitchCafé is free open source software, based on {Glitchsoc} which is a friendly fork of {Mastodon}. You can see our source code on {github} and report bugs, request features, or contribute by emailing {admin}.'
  'onboarding.page_six.github': '{domain} runs on GlitchCafé, which is based on {Glitchsoc}, a friendly {fork} of {Mastodon}. Glitchsoc is fully compatible with all Mastodon apps and instances. GlitchCafé is free open-source software. You can view the source code on {github} and report bugs, request features, or contribute to the code by emailing {admin}.',
};

export default Object.assign({}, base_english, inherited, messages);

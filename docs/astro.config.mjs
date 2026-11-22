// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import { pluginCollapsibleSections } from '@expressive-code/plugin-collapsible-sections';

const site = 'https://nepali-utils.sarbagyastha.com.np';

export default defineConfig({
  site,
  integrations: [
    starlight({
      title: 'Nepali Utils',
      description:
        'Bikram Sambat dates, Nepali number formatting, Unicode and Preeti conversion, relative time, units and phone numbers for Dart and Flutter.',
      logo: { src: './src/assets/logo.png', replacesTitle: false },
      favicon: '/favicon.png',
      head: [
        { tag: 'link', attrs: { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' } },
      ],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/sarbagyastha/nepali_utils' },
      ],
      editLink: {
        baseUrl: 'https://github.com/sarbagyastha/nepali_utils/edit/develop/docs/',
      },
      lastUpdated: true,
      expressiveCode: {
        plugins: [pluginCollapsibleSections()],
      },
      // English only for now. Add `ne: { label: 'नेपाली', lang: 'ne' }` and
      // translated pages under src/content/docs/ne/ to ship Nepali docs.
      defaultLocale: 'root',
      locales: {
        root: { label: 'English', lang: 'en' },
      },
      sidebar: [
        {
          label: 'Try the web app',
          link: '/tool/',
          attrs: { target: '_blank' },
          badge: { text: 'App', variant: 'tip' },
        },
        {
          label: 'Getting started',
          items: [
            { label: 'Installation', slug: 'getting-started/installation' },
            { label: 'Language', slug: 'getting-started/language' },
          ],
        },
        {
          label: 'Guides',
          items: [
            { label: 'Nepali date & time', slug: 'guides/date-time' },
            { label: 'Date formatting', slug: 'guides/date-format' },
            { label: 'Number formatting', slug: 'guides/number-format' },
            { label: 'Relative time (Moment)', slug: 'guides/moment' },
            { label: 'Nepali Unicode', slug: 'guides/unicode' },
            { label: 'Preeti & Devanagari', slug: 'guides/preeti-devanagari' },
            { label: 'Measurement units', slug: 'guides/measurement' },
            { label: 'Phone numbers', slug: 'guides/phone-number' },
          ],
        },
        {
          label: 'Migration',
          items: [{ label: 'Upgrading to 4.0', slug: 'migration/v4', badge: { text: 'New', variant: 'tip' } }],
        },
        {
          label: 'Reference',
          items: [
            { label: 'API reference', slug: 'reference/api' },
            { label: 'Changelog', slug: 'reference/changelog' },
          ],
        },
      ],
    }),
  ],
});

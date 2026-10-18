import { create } from 'storybook/theming';
import logo from "#/assets/keys_optimized.png"
 
export default create({
    base: 'light',
    brandUrl: 'https://transbucket.com',
    brandTitle: `
        <div>
            <img src="${logo}" alt="" width="50" style="vertical-align: middle; margin-right: 5px;" />
            <span style="vertical-align: middle; font-size: 20px">Transbucket</span>
        </div>
    `,
    brandTarget: '_self',
    appBg: '#f9ffff',
    colorSecondary: '#0085cf',
});

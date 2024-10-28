const style = document.createElement("style")
style.textContent = `
#app_splash {
    padding: 32px;
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    opacity: 0;
    transition: opacity 300ms cubic-bezier(0, 0, 0.2, 1);
    will-change: opacity;
    z-index: 100;
    background: black url("assets/packages/a2ktik_asset/img/a2k_logo_v1_640x121.png") no-repeat center;
    background-size: 640px 121px;
    background-origin: content-box;
}

#app_splash.app-loading {
    opacity: 1;
}

@media screen and (max-width: 704px) {
    #app_splash {
        background-size: contain;
    }
}
`;
document.head.appendChild(style)
const div = document.createElement("div")
div.id = "app_splash"
div.className = "app-loading"
document.body.appendChild(div)

function p = polarfill(ax_polar,thetal,thetah,rlow,rhigh,color,alpha)
    ax_cart = axes();
    ax_cart.Position = ax_polar.Position;
    [xl,yl] = pol2cart(thetal,rlow);
    [xh,yh] = pol2cart(fliplr(thetah),fliplr(rhigh));
    p = fill([xl,xh],[yl,yh],color,'FaceAlpha',alpha,'EdgeAlpha',0,'HandleVisibility','off');
    lowerLimit = -max(get(ax_polar,'RLim'))-abs(min(get(ax_polar,'RLim')));
    upperLimit = max(get(ax_polar,'RLim'))+abs(min(get(ax_polar,'RLim')));
    xlim(ax_cart,[lowerLimit,upperLimit]); 
    ylim(ax_cart,[lowerLimit,upperLimit]);
    axis square; 
    set(ax_cart,'visible','off');
end
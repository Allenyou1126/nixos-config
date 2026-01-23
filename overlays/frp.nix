{
  ...
}:

{
  nixpkgs.overlays = [
    # overlayer1 - 参数名用 self 与 super，表达继承关系
    (self: super: {
      frp = super.frp.overrideAttrs (oldAttrs: {
        env = (oldAttrs.env or { }) // {
          GOPROXY = "https://goproxy.cn,direct";
        };
      });
    })
  ];
}

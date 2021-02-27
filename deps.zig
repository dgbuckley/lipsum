const std = @import("std");
pub const pkgs = struct {
    pub const clap = std.build.Pkg{
        .name = "clap",
        .path = ".gyro/clap-gyro-0.4.0-775a546734a4b256657a427438723dd5/pkg/clap.zig",
    };

    pub const regex = std.build.Pkg{
        .name = "regex",
        .path = ".gyro/zig-regex-dgbuckley-7809563aae0c76a4d0c8076c31829b5a8610dd73/pkg/src/regex.zig",
    };

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        @setEvalBranchQuota(1_000_000);
        inline for (std.meta.declarations(pkgs)) |decl| {
            if (decl.is_pub and decl.data == .Var) {
                artifact.addPackage(@field(pkgs, decl.name));
            }
        }
    }
};

const pow = @import("std").math.pow;

pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,

    pub inline fn from_u24(v: u24) RGB {
        const r = @as(u8, @intCast(v >> 16 & 0xFF));
        const g = @as(u8, @intCast(v >> 8 & 0xFF));
        const b = @as(u8, @intCast(v & 0xFF));
        return .{ .r = r, .g = g, .b = b };
    }

    pub inline fn to_u24(v: RGB) u24 {
        const r = @as(u24, @intCast(v.r)) << 16;
        const g = @as(u24, @intCast(v.g)) << 8;
        const b = @as(u24, @intCast(v.b));
        return r | b | g;
    }

    pub fn contrast(a_: RGB, b_: RGB) f32 {
        const a = RGBf.from_RGB(a_).luminance();
        const b = RGBf.from_RGB(b_).luminance();
        return (@max(a, b) + 0.05) / (@min(a, b) + 0.05);
    }

    pub fn max_contrast(v: RGB, a: RGB, b: RGB) RGB {
        return if (contrast(v, a) > contrast(v, b)) a else b;
    }
};

pub const RGBf = struct {
    r: f32,
    g: f32,
    b: f32,

    pub inline fn from_RGB(v: RGB) RGBf {
        return .{ .r = tof(v.r), .g = tof(v.g), .b = tof(v.b) };
    }

    pub fn luminance(v: RGBf) f32 {
        return linear(v.r) * RED + linear(v.g) * GREEN + linear(v.b) * BLUE;
    }

    inline fn tof(c: u8) f32 {
        return @as(f32, @floatFromInt(c)) / 255.0;
    }

    inline fn linear(v: f32) f32 {
        return if (v <= 0.03928) v / 12.92 else pow(f32, (v + 0.055) / 1.055, GAMMA);
    }

    const RED = 0.2126;
    const GREEN = 0.7152;
    const BLUE = 0.0722;
    const GAMMA = 2.4;
};

pub fn max_contrast(v: u24, a: u24, b: u24) u24 {
    return RGB.max_contrast(RGB.from_u24(v), RGB.from_u24(a), RGB.from_u24(b)).to_u24();
}

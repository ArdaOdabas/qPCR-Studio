import Cocoa
// Renders the 1024×1024 app icon: turquoise squircle, ink amplification curve, threshold line, Cp dot.
let S: CGFloat = 1024
let img = NSImage(size: NSSize(width: S, height: S))
img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
let inset: CGFloat = 100, R = S - 2 * inset
let body = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: R, height: R), xRadius: 185, yRadius: 185)
ctx.saveGState()
let sh = NSShadow(); sh.shadowColor = NSColor(white: 0, alpha: 0.28); sh.shadowBlurRadius = 28; sh.shadowOffset = NSSize(width: 0, height: -12); sh.set()
NSColor(srgbRed: 0.039, green: 0.576, blue: 0.588, alpha: 1).setFill(); body.fill()
ctx.restoreGState()
body.addClip()
// subtle grid
NSColor(white: 1, alpha: 0.10).setStroke()
for i in stride(from: inset + 68, to: S - inset, by: 68) {
    let v = NSBezierPath(); v.move(to: NSPoint(x: i, y: inset)); v.line(to: NSPoint(x: i, y: S - inset)); v.lineWidth = 3; v.stroke()
    let h = NSBezierPath(); h.move(to: NSPoint(x: inset, y: i)); h.line(to: NSPoint(x: S - inset, y: i)); h.lineWidth = 3; h.stroke()
}
// inner frame
let frame = NSBezierPath(roundedRect: NSRect(x: inset + 34, y: inset + 34, width: R - 68, height: R - 68), xRadius: 150, yRadius: 150)
NSColor(white: 1, alpha: 0.32).setStroke(); frame.lineWidth = 6; frame.stroke()
// sigmoid
let x0 = inset + 110, x1 = S - inset - 110, yb = inset + 210, yt = S - inset - 200
func pt(_ t: CGFloat) -> NSPoint { let f = 1 / (1 + exp(-(t - 0.5) * 12)); return NSPoint(x: x0 + (x1 - x0) * t, y: yb + (yt - yb) * f) }
let thrY = yb + (yt - yb) * 0.22
let thr = NSBezierPath(); thr.move(to: NSPoint(x: x0 - 30, y: thrY)); thr.line(to: NSPoint(x: x1 + 30, y: thrY))
thr.setLineDash([22, 22], count: 2, phase: 0); thr.lineWidth = 10; thr.lineCapStyle = .round
NSColor(white: 1, alpha: 0.75).setStroke(); thr.stroke()
let curve = NSBezierPath(); curve.move(to: pt(0))
for i in 1...200 { curve.line(to: pt(CGFloat(i) / 200)) }
curve.lineWidth = 46; curve.lineCapStyle = .round; curve.lineJoinStyle = .round
NSColor(srgbRed: 0.08, green: 0.10, blue: 0.11, alpha: 1).setStroke(); curve.stroke()
// Cp dot where curve crosses the threshold
let tc = 0.5 + log(0.22 / 0.78) / 12
let c = pt(tc)
let dot = NSBezierPath(ovalIn: NSRect(x: c.x - 44, y: c.y - 44, width: 88, height: 88))
NSColor.white.setFill(); dot.fill()
NSColor(srgbRed: 0.08, green: 0.10, blue: 0.11, alpha: 1).setStroke(); dot.lineWidth = 16; dot.stroke()
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

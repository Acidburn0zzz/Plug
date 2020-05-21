import Cocoa

final class BackButtonCell: SwissArmyButtonCell {
	let normalLeftImage = NSImage(named: "Header-Back-Normal-Left")
	let normalMiddleImage = NSImage(named: "Header-Button-Normal-Middle")
	let normalRightImage = NSImage(named: "Header-Button-Normal-Right")

	let mouseDownLeftImage = NSImage(named: "Header-Back-Tap-Left")
	let mouseDownMiddleImage = NSImage(named: "Header-Button-Tap-Middle")
	let mouseDownRightImage = NSImage(named: "Header-Button-Tap-Right")

	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {
		if isMouseDown {
			NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, NSCompositingOperation.sourceOver, 1, true)
		} else {
			NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, NSCompositingOperation.sourceOver, 1, true)
		}
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		var newFrame = frame
		newFrame.origin.y += 1
		newFrame.origin.x += 3
		return super.drawTitle(title, withFrame: newFrame, in: controlView)
	}

	override func cellSize(forBounds aRect: CGRect) -> CGSize {
		var size = super.cellSize(forBounds: aRect)
		size.width += 2
		return size
	}
}

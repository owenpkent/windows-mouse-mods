# Generates docs/mouse-properties-mockup.png. Adds a "Right-Click Lock"
# section to the Win11 Mouse Properties dialog screenshot.

param(
    [string]$Source = "$env:USERPROFILE\.claude\image-cache\5fc760bc-f985-4825-bcc7-660687118067\1.png",
    [string]$Destination = "$PSScriptRoot\..\docs\mouse-properties-mockup.png"
)

Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile($Source)
$w = $src.Width
$h = $src.Height

# Insert a new section in the gap between ClickLock and the OK/Cancel/Apply row.
$insertY = 625
$insertH = 150
$newH = $h + $insertH

$bmp = New-Object System.Drawing.Bitmap $w, $newH
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Match dialog background by sampling a known empty pixel
$bgColor = $src.GetPixel(5, 90)
$g.Clear($bgColor)

# Top: copy original up to insert point
$topRect = New-Object System.Drawing.Rectangle 0, 0, $w, $insertY
$g.DrawImage($src, $topRect, $topRect, [System.Drawing.GraphicsUnit]::Pixel)

# Bottom: copy original from insert point to end, shifted down by insertH
$botSrcRect = New-Object System.Drawing.Rectangle 0, $insertY, $w, ($h - $insertY)
$botDstRect = New-Object System.Drawing.Rectangle 0, ($insertY + $insertH), $w, ($h - $insertY)
$g.DrawImage($src, $botDstRect, $botSrcRect, [System.Drawing.GraphicsUnit]::Pixel)

# ---- Draw new "Right-Click Lock" section ----
$secX = 25
$secY = $insertY + 8
$secW = $w - 50
$secH = $insertH - 16

$bodyFont = New-Object System.Drawing.Font "Segoe UI", 9
$titleFont = New-Object System.Drawing.Font "Segoe UI Semibold", 9, ([System.Drawing.FontStyle]::Regular)

# Section title sits above the card, like other sections in the dialog
$g.DrawString("Right-Click Lock", $bodyFont, [System.Drawing.Brushes]::Black, ($secX + 4), $secY)

# Card body
$cardY = $secY + 22
$cardH = $secH - 22
$cardRect = New-Object System.Drawing.Rectangle $secX, $cardY, $secW, $cardH

$cardPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$r = 6
$cardPath.AddArc($cardRect.X, $cardRect.Y, $r, $r, 180, 90)
$cardPath.AddArc($cardRect.Right - $r, $cardRect.Y, $r, $r, 270, 90)
$cardPath.AddArc($cardRect.Right - $r, $cardRect.Bottom - $r, $r, $r, 0, 90)
$cardPath.AddArc($cardRect.X, $cardRect.Bottom - $r, $r, $r, 90, 90)
$cardPath.CloseFigure()

$g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)), $cardPath)
$cardPen = New-Object System.Drawing.Pen -ArgumentList ([System.Drawing.Color]::FromArgb(220, 220, 220)), 1
$g.DrawPath($cardPen, $cardPath)

# Checkbox
$cbX = $secX + 18
$cbY = $cardY + 18
$cbSize = 14
$cbRect = New-Object System.Drawing.Rectangle $cbX, $cbY, $cbSize, $cbSize
$g.FillRectangle([System.Drawing.Brushes]::White, $cbRect)
$cbPen = New-Object System.Drawing.Pen -ArgumentList ([System.Drawing.Color]::FromArgb(140, 140, 140)), 1
$g.DrawRectangle($cbPen, $cbRect)
$g.DrawString("Turn on Right-Click Lock", $bodyFont, [System.Drawing.Brushes]::Black, ($cbX + $cbSize + 6), ($cbY - 2))

# Settings button (right-aligned to mirror ClickLock)
$btnW = 92
$btnH = 26
$btnX = $secX + $secW - $btnW - 14
$btnY = $cbY - 7
$btnRect = New-Object System.Drawing.Rectangle $btnX, $btnY, $btnW, $btnH
$btnPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$br = 4
$btnPath.AddArc($btnX, $btnY, $br, $br, 180, 90)
$btnPath.AddArc($btnX + $btnW - $br, $btnY, $br, $br, 270, 90)
$btnPath.AddArc($btnX + $btnW - $br, $btnY + $btnH - $br, $br, $br, 0, 90)
$btnPath.AddArc($btnX, $btnY + $btnH - $br, $br, $br, 90, 90)
$btnPath.CloseFigure()
$g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(253, 253, 253))), $btnPath)
$btnPen = New-Object System.Drawing.Pen -ArgumentList ([System.Drawing.Color]::FromArgb(190, 190, 190)), 1
$g.DrawPath($btnPen, $btnPath)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$btnRectF = New-Object System.Drawing.RectangleF -ArgumentList ([float]$btnX), ([float]$btnY), ([float]$btnW), ([float]$btnH)
$g.DrawString("Settings...", $bodyFont, [System.Drawing.Brushes]::Black, $btnRectF, $sf)

# Description (mirrors ClickLock copy style)
$desc = "Locks the right mouse button after a brief hold. Useful for camera control in games" + [Environment]::NewLine + "where right-click must be held continuously. Click again to release."
$g.DrawString($desc, $bodyFont, [System.Drawing.Brushes]::Black, ($cbX), ($cbY + $cbSize + 14))

# Save
$destDir = Split-Path -Parent $Destination
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
$bmp.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose(); $bmp.Dispose(); $src.Dispose()
"Saved: $Destination"

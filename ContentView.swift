import SwiftUI
import ActivityKit
import WidgetKit
import UIKit
import AVFoundation
import CoreHaptics
import UniformTypeIdentifiers

// MARK: - Tek giriş noktası
@main
enum RetroEntry {
    static func main() {
        if Bundle.main.bundleURL.pathExtension == "appex" {
            RetroIslandBundle.main()
        } else {
            MYKCyberpunk_GalagaApp.main()
        }
    }
}

// ============================================================================
// MARK: - ORTAK: ROM + Live Activity verisi + piksel çizim
// ============================================================================

struct SpriteROM {
    let width: Int
    let height: Int
    let colors: [UInt8]
    let data: [UInt8]
}

enum ROM {
    static let palette: [UInt32] = [
        0xFF000000, 0xFFFCFCFC, 0xFFD82800, 0xFFF8B800,
        0xFF0058F8, 0xFF3CBCFC, 0xFF00A800, 0xFF58D854,
        0xFF6844FC, 0xFFD800CC, 0xFFE45C10, 0xFF7C7C7C,
        0xFF3C3C3C, 0xFF0000BC, 0xFFF878F8, 0xFFAC7C00,
    ]

    static let fontCharset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ :-!./?<>ÇĞİÖŞÜ+,"

    static let font12x12: [UInt16] = [
        0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x666, 0x666, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // 0
        0x000, 0x060, 0x0E0, 0x1E0, 0x060, 0x060, 0x060, 0x060, 0x060, 0x3FC, 0x3FC, 0x000,  // 1
        0x000, 0x3FC, 0x7FE, 0x006, 0x006, 0x3FE, 0x7FC, 0x600, 0x600, 0x7FE, 0x7FE, 0x000,  // 2
        0x000, 0x7FC, 0x7FE, 0x006, 0x006, 0x1FE, 0x1FE, 0x006, 0x006, 0x7FE, 0x7FC, 0x000,  // 3
        0x000, 0x618, 0x618, 0x618, 0x618, 0x7FE, 0x7FE, 0x018, 0x018, 0x018, 0x018, 0x000,  // 4
        0x000, 0x7FE, 0x7FE, 0x600, 0x600, 0x7FC, 0x7FE, 0x006, 0x006, 0x7FE, 0x7FC, 0x000,  // 5
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x7FC, 0x7FE, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // 6
        0x000, 0x7FE, 0x7FE, 0x006, 0x00C, 0x018, 0x030, 0x060, 0x060, 0x060, 0x060, 0x000,  // 7
        0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x3FC, 0x3FC, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // 8
        0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x7FE, 0x3FE, 0x006, 0x006, 0x7FE, 0x7FC, 0x000,  // 9
        0x000, 0x0F0, 0x1F8, 0x39C, 0x70E, 0x606, 0x7FE, 0x7FE, 0x606, 0x606, 0x606, 0x000,  // A
        0x000, 0x7FC, 0x7FE, 0x606, 0x606, 0x7FC, 0x7FC, 0x606, 0x606, 0x7FE, 0x7FC, 0x000,  // B
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x600, 0x600, 0x600, 0x600, 0x7FE, 0x3FE, 0x000,  // C
        0x000, 0x7F8, 0x7FC, 0x60E, 0x606, 0x606, 0x606, 0x606, 0x60E, 0x7FC, 0x7F8, 0x000,  // D
        0x000, 0x7FE, 0x7FE, 0x600, 0x600, 0x7F8, 0x7F8, 0x600, 0x600, 0x7FE, 0x7FE, 0x000,  // E
        0x000, 0x7FE, 0x7FE, 0x600, 0x600, 0x7F8, 0x7F8, 0x600, 0x600, 0x600, 0x600, 0x000,  // F
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x63E, 0x63E, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // G
        0x000, 0x606, 0x606, 0x606, 0x606, 0x7FE, 0x7FE, 0x606, 0x606, 0x606, 0x606, 0x000,  // H
        0x000, 0x3FC, 0x3FC, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x3FC, 0x3FC, 0x000,  // I
        0x000, 0x1FE, 0x1FE, 0x018, 0x018, 0x018, 0x018, 0x618, 0x618, 0x7F8, 0x3F0, 0x000,  // J
        0x000, 0x60E, 0x61C, 0x638, 0x670, 0x7E0, 0x7E0, 0x670, 0x638, 0x61C, 0x60E, 0x000,  // K
        0x000, 0x600, 0x600, 0x600, 0x600, 0x600, 0x600, 0x600, 0x600, 0x7FE, 0x7FE, 0x000,  // L
        0x000, 0x606, 0x70E, 0x79E, 0x6F6, 0x666, 0x606, 0x606, 0x606, 0x606, 0x606, 0x000,  // M
        0x000, 0x606, 0x706, 0x786, 0x6C6, 0x666, 0x636, 0x61E, 0x60E, 0x606, 0x606, 0x000,  // N
        0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // O
        0x000, 0x7FC, 0x7FE, 0x606, 0x606, 0x7FE, 0x7FC, 0x600, 0x600, 0x600, 0x600, 0x000,  // P
        0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x606, 0x636, 0x61E, 0x60E, 0x7FE, 0x3FE, 0x000,  // Q
        0x000, 0x7FC, 0x7FE, 0x606, 0x606, 0x7FE, 0x7FC, 0x638, 0x61C, 0x60E, 0x606, 0x000,  // R
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x7FC, 0x3FE, 0x006, 0x006, 0x7FE, 0x7FC, 0x000,  // S
        0x000, 0x7FE, 0x7FE, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x000,  // T
        0x000, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // U
        0x000, 0x606, 0x606, 0x606, 0x606, 0x606, 0x70E, 0x30C, 0x39C, 0x1F8, 0x0F0, 0x000,  // V
        0x000, 0x606, 0x606, 0x606, 0x606, 0x666, 0x666, 0x6F6, 0x79E, 0x70E, 0x606, 0x000,  // W
        0x000, 0x606, 0x70E, 0x39C, 0x1F8, 0x0F0, 0x0F0, 0x1F8, 0x39C, 0x70E, 0x606, 0x000,  // X
        0x000, 0x606, 0x70E, 0x39C, 0x1F8, 0x0F0, 0x060, 0x060, 0x060, 0x060, 0x060, 0x000,  // Y
        0x000, 0x7FE, 0x7FE, 0x00E, 0x01C, 0x038, 0x070, 0x0E0, 0x1C0, 0x7FE, 0x7FE, 0x000,  // Z
        0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000,  // SPACE
        0x000, 0x000, 0x000, 0x060, 0x060, 0x000, 0x000, 0x060, 0x060, 0x000, 0x000, 0x000,  // :
        0x000, 0x000, 0x000, 0x000, 0x000, 0x3FC, 0x3FC, 0x000, 0x000, 0x000, 0x000, 0x000,  // -
        0x000, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x060, 0x000, 0x060, 0x060, 0x000,  // !
        0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x060, 0x060, 0x000,  // .
        0x000, 0x006, 0x00E, 0x01C, 0x038, 0x070, 0x0E0, 0x1C0, 0x380, 0x700, 0x600, 0x000,  // /
        0x000, 0x3FC, 0x7FE, 0x606, 0x00E, 0x03C, 0x070, 0x060, 0x000, 0x060, 0x060, 0x000,  // ?
        0x000, 0x00C, 0x01C, 0x038, 0x070, 0x0E0, 0x0E0, 0x070, 0x038, 0x01C, 0x00C, 0x000,  // <
        0x000, 0x300, 0x380, 0x1C0, 0x0E0, 0x070, 0x070, 0x0E0, 0x1C0, 0x380, 0x300, 0x000,  // >
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x600, 0x600, 0x600, 0x600, 0x7FE, 0x3FE, 0x060,  // Ç
        0x108, 0x0F0, 0x000, 0x3FE, 0x7FE, 0x600, 0x63E, 0x63E, 0x606, 0x7FE, 0x3FC, 0x000,  // Ğ
        0x060, 0x000, 0x3FC, 0x3FC, 0x060, 0x060, 0x060, 0x060, 0x060, 0x3FC, 0x3FC, 0x000,  // İ
        0x198, 0x000, 0x3FC, 0x7FE, 0x606, 0x606, 0x606, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // Ö
        0x000, 0x3FE, 0x7FE, 0x600, 0x600, 0x7FC, 0x3FE, 0x006, 0x006, 0x7FE, 0x7FC, 0x060,  // Ş
        0x198, 0x000, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x606, 0x7FE, 0x3FC, 0x000,  // Ü
        0x000, 0x000, 0x000, 0x060, 0x060, 0x3FC, 0x3FC, 0x060, 0x060, 0x000, 0x000, 0x000,  // +
        0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x000, 0x060, 0x060, 0x0C0,  // ,
    ]

    static let player = SpriteROM(width: 16, height: 16, colors: [1, 2, 5], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x07, 0xD0, 0x00,
        0x00, 0x07, 0xD0, 0x00, 0x00, 0x1F, 0xF4, 0x00, 0x00, 0x15, 0x54, 0x00, 0x00, 0x95, 0x56, 0x00,
        0x02, 0x55, 0x55, 0x80, 0x09, 0x55, 0x55, 0x60, 0x25, 0x45, 0x51, 0x58, 0x95, 0x05, 0x50, 0x56,
        0x94, 0x05, 0x50, 0x16, 0x40, 0x05, 0x50, 0x01, 0x00, 0x0A, 0xA0, 0x00, 0x00, 0x02, 0x80, 0x00,
    ])

    // Gemi 2: YILDIRIM (hızlı, ince)
    static let shipYildirim = SpriteROM(width: 16, height: 16, colors: [3, 10, 5], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x07, 0xD0, 0x00,
        0x00, 0x07, 0xD0, 0x00, 0x00, 0x16, 0x94, 0x00, 0x00, 0x56, 0x95, 0x00, 0x01, 0x5A, 0xA5, 0x40,
        0x05, 0x46, 0x91, 0x50, 0x15, 0x06, 0x90, 0x54, 0x50, 0x06, 0x90, 0x05, 0x40, 0x06, 0x90, 0x01,
        0x00, 0x06, 0x90, 0x00, 0x00, 0x0A, 0xA0, 0x00, 0x00, 0x02, 0x80, 0x00, 0x00, 0x02, 0x80, 0x00,
    ])

    // Gemi 3: KALE (ağır, zırhlı)
    static let shipKale = SpriteROM(width: 16, height: 16, colors: [11, 6, 3], data: [
        0x00, 0x05, 0x50, 0x00, 0x00, 0x15, 0x54, 0x00, 0x00, 0x17, 0xD4, 0x00, 0x00, 0x17, 0xD4, 0x00,
        0x04, 0x15, 0x54, 0x10, 0x04, 0x56, 0x95, 0x10, 0x04, 0x56, 0x95, 0x10, 0x15, 0x5A, 0xA5, 0x54,
        0x55, 0x5A, 0xA5, 0x55, 0x69, 0x15, 0x54, 0x69, 0x69, 0x06, 0x90, 0x69, 0x14, 0x06, 0x90, 0x14,
        0x00, 0x06, 0x90, 0x00, 0x00, 0x06, 0x90, 0x00, 0x00, 0x2A, 0xA8, 0x00, 0x00, 0x0A, 0xA0, 0x00,
    ])

    // Gemi 4: NİŞANCI (uzun menzil)
    static let shipNisanci = SpriteROM(width: 16, height: 16, colors: [5, 1, 3], data: [
        0x00, 0x03, 0xC0, 0x00, 0x00, 0x03, 0xC0, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0x01, 0x40, 0x00,
        0x00, 0x05, 0x50, 0x00, 0x00, 0x09, 0x60, 0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x15, 0x54, 0x00,
        0x00, 0x19, 0x64, 0x00, 0x00, 0x55, 0x55, 0x00, 0x01, 0x45, 0x51, 0x40, 0x05, 0x05, 0x50, 0x50,
        0x14, 0x05, 0x50, 0x14, 0x10, 0x0D, 0x70, 0x04, 0x00, 0x0F, 0xF0, 0x00, 0x00, 0x03, 0xC0, 0x00,
    ])

    // Gemi 5: YELPAZE (üç yönlü ateş)
    static let shipYelpaze = SpriteROM(width: 16, height: 16, colors: [9, 14, 3], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x05, 0x50, 0x00, 0x30, 0x06, 0x90, 0x0C, 0x10, 0x15, 0x54, 0x04,
        0x10, 0x19, 0x64, 0x04, 0x14, 0x55, 0x55, 0x14, 0x14, 0x55, 0x55, 0x14, 0x15, 0x55, 0x55, 0x54,
        0x55, 0xA5, 0x5A, 0x55, 0x55, 0x55, 0x55, 0x55, 0x45, 0x55, 0x55, 0x51, 0x41, 0x45, 0x51, 0x41,
        0x01, 0x05, 0x50, 0x40, 0x00, 0x09, 0x60, 0x00, 0x00, 0x32, 0x8C, 0x00, 0x00, 0x0F, 0xF0, 0x00,
    ])

    // Gemi 6: GÖLGE (hayalet hız)
    static let shipGolge = SpriteROM(width: 16, height: 16, colors: [8, 5, 1], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x01, 0x40, 0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x07, 0xD0, 0x00,
        0x00, 0x05, 0x50, 0x00, 0x00, 0x15, 0x54, 0x00, 0x00, 0x15, 0x54, 0x00, 0x00, 0x59, 0x65, 0x00,
        0x01, 0x59, 0x65, 0x40, 0x05, 0x59, 0x65, 0x50, 0x15, 0x55, 0x55, 0x54, 0x55, 0x45, 0x51, 0x55,
        0x50, 0x05, 0x50, 0x05, 0x40, 0x09, 0x60, 0x01, 0x00, 0x0A, 0xA0, 0x00, 0x00, 0x02, 0x80, 0x00,
    ])

    // Gemi 7: TOPÇU (ağır top)
    static let shipTopcu = SpriteROM(width: 16, height: 16, colors: [10, 3, 2], data: [
        0x02, 0x80, 0x02, 0x80, 0x02, 0x80, 0x02, 0x80, 0x01, 0x42, 0x81, 0x40, 0x01, 0x45, 0x51, 0x40,
        0x15, 0x55, 0x55, 0x54, 0x15, 0x75, 0x5D, 0x54, 0x15, 0x55, 0x55, 0x54, 0x55, 0x55, 0x55, 0x55,
        0x5A, 0xA5, 0x5A, 0xA5, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x15, 0x55, 0x55, 0x54,
        0x14, 0x15, 0x54, 0x14, 0x14, 0x05, 0x50, 0x14, 0x3C, 0x0F, 0xF0, 0x3C, 0x0C, 0x03, 0xC0, 0x30,
    ])

    // Gemi 8: DAYANIKLI (en çok can)
    static let shipDayanikli = SpriteROM(width: 16, height: 16, colors: [7, 6, 1], data: [
        0x00, 0x02, 0x80, 0x00, 0x00, 0x06, 0x90, 0x00, 0x00, 0x16, 0x94, 0x00, 0x00, 0x56, 0x95, 0x00,
        0x00, 0x57, 0xD5, 0x00, 0x01, 0x67, 0xD9, 0x40, 0x01, 0x67, 0xD9, 0x40, 0x05, 0xA5, 0x5A, 0x50,
        0x05, 0x55, 0x55, 0x50, 0x16, 0xA5, 0x5A, 0x94, 0x15, 0x55, 0x55, 0x54, 0x51, 0x54, 0x15, 0x45,
        0x51, 0x05, 0x50, 0x45, 0x41, 0x01, 0x40, 0x41, 0x02, 0x02, 0x80, 0x80, 0x02, 0x02, 0x80, 0x80,
    ])

    // Gemi 9: ÖFKE (çılgın ateş)
    static let shipOfke = SpriteROM(width: 16, height: 16, colors: [2, 3, 1], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x01, 0x40, 0x00, 0x10, 0x05, 0x50, 0x04, 0x10, 0x07, 0xD0, 0x04,
        0x14, 0x15, 0x54, 0x14, 0x14, 0x15, 0x54, 0x14, 0x15, 0x19, 0x64, 0x54, 0x15, 0x55, 0x55, 0x54,
        0x15, 0x55, 0x55, 0x54, 0x59, 0x55, 0x55, 0x65, 0x51, 0x45, 0x51, 0x45, 0x41, 0x41, 0x41, 0x41,
        0x40, 0x41, 0x41, 0x01, 0x00, 0x82, 0x82, 0x00, 0x00, 0x22, 0x88, 0x00, 0x00, 0x0A, 0xA0, 0x00,
    ])

    // Gemi 10: KOMUTAN (elit)
    static let shipKomutan = SpriteROM(width: 16, height: 16, colors: [3, 1, 2], data: [
        0x00, 0x01, 0x40, 0x00, 0x00, 0x05, 0x50, 0x00, 0x00, 0x09, 0x60, 0x00, 0x00, 0x15, 0x54, 0x00,
        0x00, 0x1D, 0x74, 0x00, 0x00, 0x55, 0x55, 0x00, 0x01, 0x55, 0x55, 0x40, 0x05, 0x65, 0x59, 0x50,
        0x15, 0xA9, 0x6A, 0x54, 0x55, 0xA9, 0x6A, 0x55, 0x45, 0x55, 0x55, 0x51, 0x41, 0x15, 0x54, 0x41,
        0x80, 0x45, 0x51, 0x02, 0x80, 0x13, 0xC4, 0x02, 0x00, 0x0F, 0xF0, 0x00, 0x00, 0x03, 0xC0, 0x00,
    ])

    /// Komutan'ın yardımcı askerleri: yeşil/lime gövde, sarı burun
    static let soldier = SpriteROM(width: 16, height: 16, colors: [6, 7, 3], data: [
        0x00, 0x03, 0xC0, 0x00,
        0x00, 0x01, 0x40, 0x00,
        0x00, 0x05, 0x50, 0x00,
        0x00, 0x05, 0x50, 0x00,
        0x00, 0x15, 0x54, 0x00,
        0x00, 0x19, 0x64, 0x00,
        0x00, 0x55, 0x55, 0x00,
        0x01, 0x59, 0x65, 0x40,
        0x05, 0x59, 0x65, 0x50,
        0x05, 0x55, 0x55, 0x50,
        0x11, 0x45, 0x51, 0x44,
        0x11, 0x05, 0x50, 0x44,
        0x21, 0x01, 0x40, 0x48,
        0x02, 0x00, 0x00, 0x80,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
    ])

    static let droneA = SpriteROM(width: 16, height: 16, colors: [1, 5, 2], data: [
        0x00, 0xC0, 0x03, 0x00, 0x00, 0x80, 0x02, 0x00, 0x01, 0x55, 0x55, 0x40, 0x05, 0x55, 0x55, 0x50,
        0x06, 0xAA, 0xAA, 0x90, 0x06, 0xFA, 0xAF, 0x90, 0x06, 0xFA, 0xAF, 0x90, 0x06, 0xAA, 0xAA, 0x90,
        0x05, 0x55, 0x55, 0x50, 0x29, 0x55, 0x55, 0x68, 0x21, 0x99, 0x66, 0x48, 0x21, 0x55, 0x55, 0x48,
        0x31, 0x55, 0x55, 0x4C, 0x00, 0xA0, 0x0A, 0x00, 0x02, 0xA0, 0x0A, 0x80, 0x00, 0x00, 0x00, 0x00,
    ])

    static let droneB = SpriteROM(width: 16, height: 16, colors: [1, 5, 2], data: [
        0x00, 0x80, 0x02, 0x00, 0x00, 0x80, 0x02, 0x00, 0x01, 0x55, 0x55, 0x40, 0x05, 0x55, 0x55, 0x50,
        0x06, 0xAA, 0xAA, 0x90, 0x06, 0xAA, 0xAA, 0x90, 0x36, 0xFA, 0xAF, 0x9C, 0x26, 0xAA, 0xAA, 0x98,
        0x25, 0x55, 0x55, 0x58, 0x29, 0x55, 0x55, 0x68, 0x01, 0x99, 0x66, 0x40, 0x01, 0x55, 0x55, 0x40,
        0x01, 0x55, 0x55, 0x40, 0x00, 0xA0, 0x0A, 0x00, 0x00, 0xA8, 0x2A, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let mechA = SpriteROM(width: 16, height: 16, colors: [2, 1, 3], data: [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x00, 0x01, 0x55, 0x55, 0x40, 0x05, 0xAA, 0xAA, 0x50,
        0x06, 0xAF, 0xFA, 0x90, 0x06, 0xAF, 0xFA, 0x90, 0x05, 0xAA, 0xAA, 0x50, 0x55, 0x55, 0x55, 0x55,
        0x40, 0x65, 0x59, 0x01, 0x40, 0x55, 0x55, 0x01, 0x40, 0x55, 0x55, 0x01, 0x80, 0xAA, 0xAA, 0x02,
        0xA2, 0x22, 0x88, 0x8A, 0x00, 0xAA, 0xAA, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let mechB = SpriteROM(width: 16, height: 16, colors: [2, 1, 3], data: [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x00, 0x01, 0x55, 0x55, 0x40, 0x05, 0xAA, 0xAA, 0x50,
        0x06, 0xAB, 0xEA, 0x90, 0x06, 0xAB, 0xEA, 0x90, 0x05, 0xAA, 0xAA, 0x50, 0x55, 0x55, 0x55, 0x55,
        0x40, 0x65, 0x59, 0x01, 0x40, 0x55, 0x55, 0x01, 0x40, 0x55, 0x55, 0x01, 0x20, 0xAA, 0xAA, 0x08,
        0x80, 0x88, 0x22, 0x02, 0x00, 0xAA, 0xAA, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let bossA = SpriteROM(width: 32, height: 24, colors: [5, 4, 3], data: [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x00, 0x30, 0x00, 0x00,
        0x00, 0x00, 0x08, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x55, 0x55, 0x00, 0x00,
        0x00, 0x01, 0x55, 0x55, 0x55, 0x55, 0x40, 0x00, 0x00, 0x01, 0x6A, 0xAA, 0xAA, 0xA9, 0x40, 0x00,
        0x00, 0x01, 0x6F, 0xEA, 0xAB, 0xF9, 0x40, 0x00, 0x00, 0x01, 0x6A, 0xAA, 0xAA, 0xA9, 0x40, 0x00,
        0x00, 0x01, 0x55, 0x55, 0x55, 0x55, 0x40, 0x00, 0x2A, 0x80, 0x00, 0x55, 0x55, 0x00, 0x02, 0xA8,
        0xAA, 0xA0, 0x55, 0x55, 0x55, 0x55, 0x0A, 0xAA, 0xAA, 0xA5, 0x55, 0x55, 0x55, 0x55, 0x5A, 0xAA,
        0xAA, 0xA1, 0x55, 0x5F, 0xF5, 0x55, 0x4A, 0xAA, 0x2A, 0x81, 0x55, 0x5F, 0xF5, 0x55, 0x42, 0xA8,
        0x10, 0x41, 0x55, 0x55, 0x55, 0x55, 0x41, 0x04, 0x10, 0x40, 0x55, 0x55, 0x55, 0x55, 0x01, 0x04,
        0x00, 0x00, 0x55, 0x55, 0x55, 0x55, 0x00, 0x00, 0x00, 0x00, 0x05, 0x50, 0x05, 0x50, 0x00, 0x00,
        0x00, 0x00, 0x05, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x50, 0x00, 0x00,
        0x00, 0x00, 0x2A, 0x80, 0x02, 0xA8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let bossB = SpriteROM(width: 32, height: 24, colors: [5, 4, 3], data: [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x20, 0x00, 0x00,
        0x00, 0x00, 0x08, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x55, 0x55, 0x55, 0x55, 0x00, 0x00,
        0x00, 0x01, 0x55, 0x55, 0x55, 0x55, 0x40, 0x00, 0x00, 0x01, 0x6A, 0xAA, 0xAA, 0xA9, 0x40, 0x00,
        0x00, 0x01, 0x6F, 0xEA, 0xAB, 0xF9, 0x40, 0x00, 0x00, 0x01, 0x6A, 0xAA, 0xAA, 0xA9, 0x40, 0x00,
        0x00, 0x01, 0x55, 0x55, 0x55, 0x55, 0x40, 0x00, 0x2A, 0x80, 0x00, 0x55, 0x55, 0x00, 0x02, 0xA8,
        0xAA, 0xA0, 0x55, 0x55, 0x55, 0x55, 0x0A, 0xAA, 0xAA, 0xA5, 0x55, 0x55, 0x55, 0x55, 0x5A, 0xAA,
        0xAA, 0xA1, 0x55, 0x5F, 0xF5, 0x55, 0x4A, 0xAA, 0x2A, 0x81, 0x55, 0x5F, 0xF5, 0x55, 0x42, 0xA8,
        0x10, 0x41, 0x55, 0x55, 0x55, 0x55, 0x41, 0x04, 0x30, 0xC0, 0x55, 0x55, 0x55, 0x55, 0x03, 0x0C,
        0x00, 0x00, 0x55, 0x55, 0x55, 0x55, 0x00, 0x00, 0x00, 0x00, 0x05, 0x50, 0x05, 0x50, 0x00, 0x00,
        0x00, 0x00, 0x05, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x50, 0x00, 0x00,
        0x00, 0x00, 0x2A, 0x80, 0x02, 0xA8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let explosion1 = SpriteROM(width: 16, height: 16, colors: [3, 2, 1], data: [
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x08, 0x20, 0x00, 0x00, 0x21, 0x48, 0x00, 0x00, 0x07, 0xD0, 0x00, 0x00, 0x27, 0xD8, 0x00,
        0x00, 0x27, 0xD8, 0x00, 0x00, 0x07, 0xD0, 0x00, 0x00, 0x21, 0x48, 0x00, 0x00, 0x08, 0x20, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ])

    static let explosion2 = SpriteROM(width: 16, height: 16, colors: [3, 2, 1], data: [
        0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x20, 0x02, 0x04, 0x10, 0x80, 0x00, 0x42, 0x81, 0x00,
        0x04, 0x30, 0x0C, 0x10, 0x00, 0xF1, 0x4F, 0x00, 0x21, 0x3F, 0xFC, 0x48, 0x02, 0x3F, 0xFC, 0x80,
        0x02, 0x3F, 0xFC, 0x80, 0x21, 0x3F, 0xFC, 0x48, 0x00, 0xF1, 0x4F, 0x00, 0x04, 0x30, 0x0C, 0x10,
        0x00, 0x42, 0x81, 0x00, 0x02, 0x04, 0x10, 0x80, 0x08, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00,
    ])

    static let explosion3 = SpriteROM(width: 16, height: 16, colors: [3, 2, 1], data: [
        0x80, 0x00, 0x00, 0x02, 0x20, 0x10, 0x04, 0x08, 0x02, 0x00, 0x00, 0x80, 0x10, 0x08, 0x20, 0x04,
        0x02, 0x00, 0x00, 0x80, 0x80, 0x01, 0x40, 0x02, 0x01, 0x20, 0x08, 0x40, 0x20, 0x08, 0x20, 0x08,
        0x20, 0x08, 0x20, 0x08, 0x01, 0x20, 0x08, 0x40, 0x80, 0x01, 0x40, 0x02, 0x02, 0x00, 0x00, 0x80,
        0x10, 0x08, 0x20, 0x04, 0x02, 0x00, 0x00, 0x80, 0x20, 0x10, 0x04, 0x08, 0x80, 0x00, 0x00, 0x02,
    ])

    static let heart = SpriteROM(width: 8, height: 8, colors: [1, 2, 1], data: [
        0x28, 0x28, 0xBA, 0xAA, 0xAA, 0xAA, 0xAA, 0xAA, 0x2A, 0xA8, 0x0A, 0xA0, 0x02, 0x80, 0x00, 0x00,
    ])

    static let flag = SpriteROM(width: 8, height: 8, colors: [2, 3, 1], data: [
        0xBF, 0xC0, 0xBF, 0x50, 0xB5, 0x55, 0xB5, 0x00, 0x90, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00,
    ])

    static let pauseIcon = SpriteROM(width: 8, height: 8, colors: [1, 1, 1], data: [
        0x00, 0x00, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x00, 0x00,
    ])
}

// MARK: - Live Activity
struct GalagaActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var skor: Int
        var bolum: Int
        var can: Double
        var durum: String
        var bossVar: Bool
    }
    var oyuncu: String
}

enum RetroGlyphs {
    static let index: [Character: Int] = {
        var d: [Character: Int] = [:]
        for (i, ch) in ROM.fontCharset.enumerated() { d[ch] = i }
        return d
    }()
}

enum RetroColor {
    static func color(_ i: UInt8) -> Color {
        let v = ROM.palette[Int(i)]
        return Color(red: Double((v >> 16) & 0xFF) / 255,
                     green: Double((v >> 8) & 0xFF) / 255,
                     blue: Double(v & 0xFF) / 255)
    }
}

struct PixelTextShape: Shape {
    let text: String
    func path(in rect: CGRect) -> Path {
        let chars = Array(text.uppercased())
        guard !chars.isEmpty else { return Path() }
        let px = min(rect.width / CGFloat(chars.count * 12), rect.height / 12)
        var p = Path()
        for (i, ch) in chars.enumerated() {
            guard let g = RetroGlyphs.index[ch] else { continue }
            for row in 0..<12 {
                let bits = ROM.font12x12[g * 12 + row]
                if bits == 0 { continue }
                for col in 0..<12 where bits & (UInt16(0x800) >> UInt16(col)) != 0 {
                    p.addRect(CGRect(x: rect.minX + CGFloat(i * 12 + col) * px,
                                     y: rect.minY + CGFloat(row) * px,
                                     width: px, height: px))
                }
            }
        }
        return p
    }
}

struct PixelText: View {
    let text: String
    var color: Color = .white
    var pixel: CGFloat = 1

    var body: some View {
        PixelTextShape(text: text)
            .fill(color)
            .frame(width: CGFloat(text.count * 12) * pixel, height: 12 * pixel)
    }
}

struct PixelSpriteShape: Shape {
    let rom: SpriteROM
    let slot: UInt8

    func path(in rect: CGRect) -> Path {
        let px = min(rect.width / CGFloat(rom.width), rect.height / CGFloat(rom.height))
        let bytesPerRow = (rom.width + 3) / 4
        var p = Path()
        for y in 0..<rom.height {
            for x in 0..<rom.width {
                let byte = rom.data[y * bytesPerRow + x / 4]
                let v = (byte >> UInt8(6 - (x % 4) * 2)) & 0x03
                if v == slot {
                    p.addRect(CGRect(x: rect.minX + CGFloat(x) * px, y: rect.minY + CGFloat(y) * px,
                                     width: px, height: px))
                }
            }
        }
        return p
    }
}

struct PixelSprite: View {
    let rom: SpriteROM
    var pixel: CGFloat = 1

    var body: some View {
        ZStack {
            ForEach(1...3, id: \.self) { slot in
                PixelSpriteShape(rom: rom, slot: UInt8(slot))
                    .fill(RetroColor.color(rom.colors[slot - 1]))
            }
        }
        .frame(width: CGFloat(rom.width) * pixel, height: CGFloat(rom.height) * pixel)
    }
}

struct RetroIslandBundle: WidgetBundle {
    var body: some Widget {
        GalagaLiveActivity()
    }
}

private enum Fmt {
    static func two(_ n: Int) -> String { String(format: "%02d", min(max(n, 0), 99)) }
    static func six(_ n: Int) -> String { String(format: "%06d", min(max(n, 0), 999_999)) }
    static func short(_ n: Int) -> String { String(min(max(n, 0), 999_999)) }
}

private let retroYellow = RetroColor.color(3)
private let retroRed = RetroColor.color(2)
private let retroCyan = RetroColor.color(5)
private let retroLime = RetroColor.color(7)

private func statusColor(_ s: GalagaActivityAttributes.ContentState) -> Color {
    if s.durum == "MOLA" { return retroYellow }
    return s.bossVar ? retroRed : retroLime
}

struct GalagaLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GalagaActivityAttributes.self) { context in
            HStack(alignment: .center, spacing: 12) {
                PixelSprite(rom: context.state.bossVar ? ROM.bossA : ROM.player, pixel: context.state.bossVar ? 1.5 : 2.5)
                VStack(alignment: .leading, spacing: 6) {
                    PixelText(text: context.state.durum, color: statusColor(context.state), pixel: 1.5)
                    PixelText(text: "SKOR " + Fmt.six(context.state.skor), color: .white, pixel: 1)
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 6) {
                    PixelText(text: "BÖLÜM " + Fmt.two(context.state.bolum), color: retroCyan, pixel: 1)
                }
            }
            .padding(16)
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let s = context.state
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        PixelText(text: "SKOR", color: retroRed, pixel: 1)
                        PixelText(text: Fmt.short(s.skor), color: .white, pixel: 1.25)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        PixelText(text: "BÖLÜM", color: retroCyan, pixel: 1)
                        PixelText(text: Fmt.two(s.bolum), color: .white, pixel: 1.25)
                    }
                    .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.center) {
                    PixelText(text: s.durum, color: statusColor(s), pixel: 1.25)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(alignment: .center) {
                        PixelSprite(rom: ROM.player, pixel: 1.5)
                        Spacer(minLength: 8)
                        if s.durum == "MOLA" {
                            PixelText(text: "DEVAM İÇİN DOKUN", color: retroYellow, pixel: 0.75)
                            Spacer(minLength: 8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            } compactLeading: {
                PixelSprite(rom: ROM.player, pixel: 1.25)
            } compactTrailing: {
                PixelText(text: Fmt.short(s.skor), color: statusColor(s), pixel: 0.8)
            } minimal: {
                PixelSprite(rom: s.bossVar ? ROM.bossA : ROM.player, pixel: s.bossVar ? 0.6 : 1.1)
            }
            .keylineTint(statusColor(s))
        }
    }
}

// ============================================================================
// MARK: - OYUN MÜZİK VE MOTORU
// ============================================================================

enum Pal {
    static let black: UInt8 = 0, white: UInt8 = 1, red: UInt8 = 2, yellow: UInt8 = 3
    static let blue: UInt8 = 4, cyan: UInt8 = 5, green: UInt8 = 6, lime: UInt8 = 7
    static let purple: UInt8 = 8, magenta: UInt8 = 9, orange: UInt8 = 10, gray: UInt8 = 11
    static let dark: UInt8 = 12, navy: UInt8 = 13, pink: UInt8 = 14, brown: UInt8 = 15
    static let shield: UInt8 = 5 // Açık mavi (Cyan)
    static let shieldHighlight: UInt8 = 1 // Beyaz parıltı
    /// Kalkan katman renkleri: 1. katman cyan, 2. lime, 3. sarı
    static let shieldLayerColors: [UInt8] = [5, 7, 3]
}

enum Layout {
    static let width = 224
    static let fieldHeight = 288
    static let minPanelHeight = 44
    static let maxPanelHeight = 120
    static let hudTop = 26
    static let fieldBottom = 275
    static let playerY = 256
}

struct Sprite {
    let width: Int
    let height: Int
    let pixels: [UInt8]
    let colors: [UInt8]

    init(_ rom: SpriteROM) {
        width = rom.width
        height = rom.height
        colors = rom.colors
        let bytesPerRow = (rom.width + 3) / 4
        var px = [UInt8](repeating: 0, count: rom.width * rom.height)
        for y in 0..<rom.height {
            for x in 0..<rom.width {
                let byte = rom.data[y * bytesPerRow + x / 4]
                let shift = UInt8(6 - (x % 4) * 2)
                px[y * rom.width + x] = (byte >> shift) & 0x03
            }
        }
        pixels = px
    }
}

enum Gfx {
    static let player = Sprite(ROM.player)
    static let ships = [Sprite(ROM.player), Sprite(ROM.shipYildirim), Sprite(ROM.shipKale),
                        Sprite(ROM.shipNisanci), Sprite(ROM.shipYelpaze), Sprite(ROM.shipGolge),
                        Sprite(ROM.shipTopcu), Sprite(ROM.shipDayanikli), Sprite(ROM.shipOfke),
                        Sprite(ROM.shipKomutan)]
    static let soldier = Sprite(ROM.soldier)
    static let drone = [Sprite(ROM.droneA), Sprite(ROM.droneB)]
    static let mech = [Sprite(ROM.mechA), Sprite(ROM.mechB)]
    static let boss = [Sprite(ROM.bossA), Sprite(ROM.bossB)]
    static let explosion = [Sprite(ROM.explosion1), Sprite(ROM.explosion2), Sprite(ROM.explosion3)]
    static let heart = Sprite(ROM.heart)
    static let flag = Sprite(ROM.flag)
    static let pause = Sprite(ROM.pauseIcon)
    static let glyphIndex: [Character: Int] = {
        var d: [Character: Int] = [:]
        for (i, ch) in ROM.fontCharset.enumerated() { d[ch] = i }
        return d
    }()
}

final class Framebuffer {
    let width: Int
    private(set) var height: Int
    private(set) var pixels: [UInt32]
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        pixels = [UInt32](repeating: ROM.palette[0], count: width * height)
    }

    func resize(height newHeight: Int) {
        guard newHeight > 0, newHeight != height else { return }
        height = newHeight
        pixels = [UInt32](repeating: ROM.palette[0], count: width * newHeight)
    }

    /// Tamamen saydam temizler (arkadaki yıldız katmanı görünür kalır).
    func clearTransparent() {
        pixels.withUnsafeMutableBufferPointer { buf in
            for i in 0..<buf.count { buf[i] = 0 }
        }
    }

    func clear(_ c: UInt8) {
        let v = ROM.palette[Int(c)]
        pixels.withUnsafeMutableBufferPointer { buf in
            for i in 0..<buf.count { buf[i] = v }
        }
    }

    @inline(__always)
    func put(_ x: Int, _ y: Int, _ c: UInt8) {
        guard x >= 0, y >= 0, x < width, y < height else { return }
        pixels[y * width + x] = ROM.palette[Int(c)]
    }

    func fill(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: UInt8) {
        let x0 = max(0, x), y0 = max(0, y)
        let x1 = min(width, x + w), y1 = min(height, y + h)
        guard x0 < x1, y0 < y1 else { return }
        let v = ROM.palette[Int(c)]
        let stride = width
        pixels.withUnsafeMutableBufferPointer { buf in
            for yy in y0..<y1 {
                let row = yy * stride
                for xx in x0..<x1 { buf[row + xx] = v }
            }
        }
    }

    func rect(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: UInt8) {
        fill(x, y, w, 1, c)
        fill(x, y + h - 1, w, 1, c)
        fill(x, y, 1, h, c)
        fill(x + w - 1, y, 1, h, c)
    }

    func dither(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: UInt8) {
        for yy in y..<(y + h) {
            for xx in x..<(x + w) where (xx + yy) % 2 == 0 { put(xx, yy, c) }
        }
    }

    /// Piksel dairesi (çember çizgisi). dithered = true ise satranç deseniyle yarı saydam görünür.
    func circle(_ cx: Int, _ cy: Int, _ r: Int, _ c: UInt8, dithered: Bool = false) {
        guard r > 0 else { return }
        let steps = max(16, r * 8)
        for i in 0..<steps {
            let a = Double(i) / Double(steps) * 2.0 * Double.pi
            let x = cx + Int((Double(r) * cos(a)).rounded())
            let y = cy + Int((Double(r) * sin(a)).rounded())
            if dithered && (x + y) % 2 != 0 { continue }
            put(x, y, c)
        }
    }

    /// Dolu piksel dairesi.
    func disc(_ cx: Int, _ cy: Int, _ r: Int, _ c: UInt8) {
        guard r >= 0 else { return }
        for dy in -r...r {
            for dx in -r...r where dx * dx + dy * dy <= r * r + r {
                put(cx + dx, cy + dy, c)
            }
        }
    }

    func blit(_ s: Sprite, _ x: Int, _ y: Int, colors: [UInt8]? = nil) {
        let cols = colors ?? s.colors
        for sy in 0..<s.height {
            let py = y + sy
            if py < 0 || py >= height { continue }
            for sx in 0..<s.width {
                let idx = s.pixels[sy * s.width + sx]
                if idx == 0 { continue }
                let px = x + sx
                if px < 0 || px >= width { continue }
                pixels[py * width + px] = ROM.palette[Int(cols[Int(idx) - 1])]
            }
        }
    }

    /// Sprite'ı tam sayı katıyla (ör. 2x) büyütür; piksel bloklarını korur.
    func blitScaledInt(_ s: Sprite, _ x: Int, _ y: Int, scale: Int, colors: [UInt8]? = nil) {
        let cols = colors ?? s.colors
        for sy in 0..<s.height {
            for sx in 0..<s.width {
                let idx = s.pixels[sy * s.width + sx]
                if idx == 0 { continue }
                let v = ROM.palette[Int(cols[Int(idx) - 1])]
                for dy in 0..<scale {
                    let py = y + sy * scale + dy
                    if py < 0 || py >= height { continue }
                    for dx in 0..<scale {
                        let px = x + sx * scale + dx
                        if px < 0 || px >= width { continue }
                        pixels[py * width + px] = v
                    }
                }
            }
        }
    }

    func blitScaled(_ s: Sprite, _ x: Int, _ y: Int, targetSize: Int, colors: [UInt8]? = nil) {
        let cols = colors ?? s.colors
        let sw = s.width, sh = s.height
        let tw = targetSize, th = targetSize
        for ty in 0..<th {
            let py = y + ty
            if py < 0 || py >= height { continue }
            let sy = (ty * sh) / th
            for tx in 0..<tw {
                let px = x + tx
                if px < 0 || px >= width { continue }
                let sx = (tx * sw) / tw
                let idx = s.pixels[sy * sw + sx]
                if idx == 0 { continue }
                pixels[py * width + px] = ROM.palette[Int(cols[Int(idx) - 1])]
            }
        }
    }

    static func textWidth(_ s: String, scale: Int = 1) -> Int { s.count * 12 * scale }

    func text(_ str: String, _ x: Int, _ y: Int, _ c: UInt8, scale: Int = 1) {
        var cx = x
        for ch in str.uppercased() {
            if let g = Gfx.glyphIndex[ch] {
                for row in 0..<12 {
                    let bits = ROM.font12x12[g * 12 + row]
                    if bits == 0 { continue }
                    for col in 0..<12 where bits & (UInt16(0x800) >> UInt16(col)) != 0 {
                        if scale == 1 {
                            put(cx + col, y + row, c)
                        } else {
                            fill(cx + col * scale, y + row * scale, scale, scale, c)
                        }
                    }
                }
            }
            cx += 12 * scale
        }
    }

    func textCentered(_ s: String, y: Int, _ c: UInt8, scale: Int = 1) {
        text(s, (width - Framebuffer.textWidth(s, scale: scale)) / 2, y, c, scale: scale)
    }

    func makeImage() -> CGImage? {
        let data = pixels.withUnsafeBufferPointer { Data(buffer: $0) }
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        let info = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
                       bytesPerRow: width * 4, space: colorSpace, bitmapInfo: info,
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}

// MARK: - Ayarlar (kalıcı)
final class GameSettings: @unchecked Sendable {
    static let shared = GameSettings()
    var sfxOn: Bool { didSet { UserDefaults.standard.set(sfxOn, forKey: "ayar.ses") } }
    var musicOn: Bool { didSet { UserDefaults.standard.set(musicOn, forKey: "ayar.muzik") } }
    var hapticOn: Bool { didSet { UserDefaults.standard.set(hapticOn, forKey: "ayar.titresim") } }
    /// Ses seviyeleri (0...1)
    var sfxVolume: Double { didSet { UserDefaults.standard.set(sfxVolume, forKey: "ayar.sesSeviye") } }
    var musicVolume: Double { didSet { UserDefaults.standard.set(musicVolume, forKey: "ayar.muzikSeviye") } }
    var shipIndex: Int { didSet { UserDefaults.standard.set(shipIndex, forKey: "ayar.gemi") } }
    /// Herhangi bir oyunda 20000 puana ulaşılınca özel yetenekli gemiler kalıcı olarak açılır.
    var specialOpen: Bool { didSet { UserDefaults.standard.set(specialOpen, forKey: "ayar.ozelAcik") } }

    private init() {
        let d = UserDefaults.standard
        sfxOn = d.object(forKey: "ayar.ses") as? Bool ?? true
        musicOn = d.object(forKey: "ayar.muzik") as? Bool ?? true
        hapticOn = d.object(forKey: "ayar.titresim") as? Bool ?? true
        sfxVolume = min(max(d.object(forKey: "ayar.sesSeviye") as? Double ?? 1.0, 0), 1)
        musicVolume = min(max(d.object(forKey: "ayar.muzikSeviye") as? Double ?? 1.0, 0), 1)
        shipIndex = min(max(d.object(forKey: "ayar.gemi") as? Int ?? 0, 0), Ship.allCases.count - 1)
        specialOpen = d.object(forKey: "ayar.ozelAcik") as? Bool ?? false
    }
}

// MARK: - Taptic Engine (Haptics)
final class RetroHaptic {
    static let shared = RetroHaptic()
    private let lightGen = UIImpactFeedbackGenerator(style: .light)
    private let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen = UIImpactFeedbackGenerator(style: .heavy)
    private let notifGen = UINotificationFeedbackGenerator()
    private let selectionGen = UISelectionFeedbackGenerator()
    private let rigidGen = UIImpactFeedbackGenerator(style: .rigid)

    private init() {
        lightGen.prepare(); mediumGen.prepare(); heavyGen.prepare(); rigidGen.prepare(); notifGen.prepare(); selectionGen.prepare()
    }

    private var on: Bool { GameSettings.shared.hapticOn }
    // Tüm titreşimler en güçlü darbe (heavy, yoğunluk 1.0) ile verilir.
    private func full() { heavyGen.impactOccurred(intensity: 1.0); heavyGen.prepare() }
    func tap() { guard on else { return }; full() }
    func shoot() { guard on else { return }; full() }
    func hit() { guard on else { return }; full() }
    func explode() {
        guard on else { return }
        full()
        rigidGen.impactOccurred(intensity: 1.0); rigidGen.prepare()
    }
    func success() { guard on else { return }; notifGen.notificationOccurred(.success) }
    func error() { guard on else { return }; notifGen.notificationOccurred(.error) }
}

// MARK: - 8-bit Ses & Müzik Motoru
final class RetroSound {
    enum Sfx: CaseIterable { case shoot, enemyHit, bossHit, playerHit, stage, gameOver, blip, heartPickup, powerUp, bomb, shieldBreak }

    private struct Seg { let f0: Double; let f1: Double; let dur: Double; let noise: Bool }

    private let engine = AVAudioEngine()
    private var players: [AVAudioPlayerNode] = []
    private var buffers: [Sfx: AVAudioPCMBuffer] = [:]
    private var nextPlayer = 0
    private let format: AVAudioFormat
    private var enabled = true

    // Arka plan müziği
    enum Track { case menu, normal, normal2, boss, bigBoss }
    private let musicPlayer = AVAudioPlayerNode()
    private var musicBuffers: [Track: AVAudioPCMBuffer] = [:]
    private var wantedTrack: Track?
    private var currentTrack: Track?

    init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 22050, channels: 1)!
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        for _ in 0..<4 {
            let p = AVAudioPlayerNode()
            engine.attach(p)
            engine.connect(p, to: engine.mainMixerNode, format: format)
            players.append(p)
        }
        engine.attach(musicPlayer)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.35
        applyVolumes()
        for s in Sfx.allCases { buffers[s] = synth(s) }
        // Müzik parçaları arka planda üretilir (oyun açılışını geciktirmesin)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            for t in [Track.menu, Track.normal, Track.boss, Track.normal2, Track.bigBoss] {
                guard let me = self else { return }
                let buf = me.synthMusic(t)
                DispatchQueue.main.async { [weak self] in
                    guard let me = self else { return }
                    me.musicBuffers[t] = buf
                    if me.wantedTrack == t { me.applyMusic() }
                }
            }
        }
        do {
            try engine.start()
            players.forEach { $0.play() }
        } catch {
            enabled = false
        }
    }

    // MARK: Müzik kontrolü
    /// Oyunun o an istediği parça (nil = sessiz). Değişince çalmayı günceller.
    func setWanted(_ t: Track?) {
        guard t != wantedTrack else { return }
        wantedTrack = t
        applyMusic()
    }

    /// Ses / müzik seviyesi ayarlarını uygular (müzik tabanı 0,5; efektler tam seviye)
    func applyVolumes() {
        let st = GameSettings.shared
        musicPlayer.volume = Float(0.5 * st.musicVolume)
        for p in players { p.volume = Float(st.sfxVolume) }
    }

    /// Ayar değişince / uygulama öne gelince müziği baştan uygular.
    func refreshMusic() {
        musicPlayer.stop()
        currentTrack = nil
        applyMusic()
    }

    private func applyMusic() {
        guard enabled else { return }
        guard GameSettings.shared.musicOn, let want = wantedTrack else {
            if currentTrack != nil { musicPlayer.stop(); currentTrack = nil }
            return
        }
        if currentTrack == want && musicPlayer.isPlaying { return }
        guard let buf = musicBuffers[want] else { return }
        if !engine.isRunning { try? engine.start() }
        musicPlayer.stop()
        musicPlayer.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        musicPlayer.play()
        currentTrack = want
    }

    // MARK: Müzik sentezi (PWM kare dalga lead, arp, üçgen bas + pad, davul, sidechain, zil, yankı)
    private struct MusicBar {
        let bass: Int       // bas kök notası (MIDI)
        let arp: [Int]      // 4 akor sesi (MIDI)
        let lead: [Int]     // 8 sekizlik: 0 = sus, -1 = önceki notayı uzat, >0 = MIDI nota
    }

    private struct MusicSpec {
        let bpm: Double
        let bars: [MusicBar]
        let bassPattern: [Int]    // 16 adım: yarım ton farkı, -99 = sus
        let arpPattern: [Int]     // 16 adım: 0...3 = akor sesi, -1 = sus
        let kick: Set<Int>
        let snare: Set<Int>
        let hat: Set<Int>
        let openHat: Set<Int>
        let denseHatBars: Set<Int>   // 16'lık hi-hat çalınan ölçüler
        let fillBars: Set<Int>       // sonunda davul fillı olan ölçüler
        let leadDuty: Double
        let leadGain: Float
        var transpose: Int = 0           // tüm notaları yarım ton kaydırır
        var padGain: Float = 0           // yumuşak akor dolgusu
        var octaveGain: Float = 0        // lead'in bir oktav altındaki ikizi (kalınlık)
        var crashBars: Set<Int> = []     // başında zil çalınan ölçüler
    }

    private func mbar(_ bass: Int, _ arp: [Int], _ lead: [Int]) -> MusicBar {
        MusicBar(bass: bass, arp: arp, lead: lead)
    }

    /// La minör: A bölümü (8 ölçü) + B bölümü (8 ölçü). Normal ve hızlı (transpoze) parça paylaşır.
    private func normalBars() -> [MusicBar] {
        let am: (Int, [Int]) = (45, [57, 60, 64, 69])
        let f: (Int, [Int]) = (41, [53, 57, 60, 65])
        let c: (Int, [Int]) = (48, [60, 64, 67, 72])
        let g: (Int, [Int]) = (43, [55, 59, 62, 67])
        let e: (Int, [Int]) = (40, [52, 56, 59, 64])
        let em: (Int, [Int]) = (40, [52, 55, 59, 64])
        let bars: [MusicBar] = [
            // A bölümü
            mbar(am.0, am.1, [81, -1, 76, 0, 72, 76, 79, -1]),
            mbar(f.0, f.1, [77, -1, 72, 0, 69, 72, 77, -1]),
            mbar(c.0, c.1, [79, -1, 76, 0, 72, 76, 79, 81]),
            mbar(g.0, g.1, [79, -1, 74, 0, 71, 74, 79, -1]),
            mbar(am.0, am.1, [81, -1, 76, 0, 72, 76, 81, 83]),
            mbar(f.0, f.1, [84, -1, 81, 0, 77, 81, 84, -1]),
            mbar(g.0, g.1, [83, 81, 79, 76, 74, 76, 79, 83]),
            mbar(e.0, e.1, [80, 83, 88, -1, 83, 80, 76, -1]),
            // B bölümü
            mbar(f.0, f.1, [77, -1, -1, 81, 84, -1, 81, 77]),
            mbar(g.0, g.1, [79, -1, -1, 83, 86, -1, 83, 79]),
            mbar(am.0, am.1, [81, -1, 76, -1, 72, 76, 81, 84]),
            mbar(em.0, em.1, [83, -1, 79, -1, 76, 79, 83, -1]),
            mbar(f.0, f.1, [84, -1, 81, -1, 77, 81, 84, 86]),
            mbar(g.0, g.1, [86, 84, 83, 81, 79, 81, 83, 86]),
            mbar(am.0, am.1, [88, -1, 84, -1, 81, 84, 88, -1]),
            mbar(e.0, e.1, [80, 0, 83, 0, 88, -1, -1, -1]),
        ]
        return bars
    }

    private func musicSpec(_ track: Track) -> MusicSpec {
        switch track {
        case .menu:
            // La minör, 108 BPM: sakin, süzülen menü müziği
            let am: (Int, [Int]) = (45, [57, 60, 64, 69])
            let f: (Int, [Int]) = (41, [53, 57, 60, 65])
            let c: (Int, [Int]) = (48, [60, 64, 67, 72])
            let g: (Int, [Int]) = (43, [55, 59, 62, 67])
            let e: (Int, [Int]) = (40, [52, 56, 59, 64])
            let em: (Int, [Int]) = (40, [52, 55, 59, 64])
            let bars: [MusicBar] = [
                mbar(am.0, am.1, [72, -1, -1, 76, 79, -1, 76, -1]),
                mbar(f.0, f.1, [77, -1, -1, 72, 69, -1, 72, -1]),
                mbar(c.0, c.1, [76, -1, -1, 79, 84, -1, 79, -1]),
                mbar(g.0, g.1, [74, -1, -1, 79, 83, -1, 79, -1]),
                mbar(am.0, am.1, [81, -1, 79, -1, 76, -1, 72, -1]),
                mbar(f.0, f.1, [77, -1, 76, -1, 72, -1, 69, -1]),
                mbar(g.0, g.1, [74, 76, 79, -1, 83, -1, 79, -1]),
                mbar(e.0, e.1, [80, -1, 83, -1, 88, -1, -1, -1]),
                mbar(f.0, f.1, [84, -1, 81, -1, 77, -1, 81, -1]),
                mbar(g.0, g.1, [83, -1, 79, -1, 74, -1, 79, -1]),
                mbar(am.0, am.1, [81, -1, 76, -1, 72, 76, 81, -1]),
                mbar(em.0, em.1, [79, -1, 76, -1, 71, 76, 79, -1]),
                mbar(f.0, f.1, [77, 81, 84, -1, 81, 77, 72, -1]),
                mbar(g.0, g.1, [79, 83, 86, -1, 83, 79, 74, -1]),
                mbar(am.0, am.1, [81, -1, 84, -1, 88, -1, 84, -1]),
                mbar(e.0, e.1, [83, -1, 80, -1, 76, -1, -1, -1]),
            ]
            return MusicSpec(
                bpm: 108, bars: bars,
                bassPattern: [0, -99, -99, 0, -99, -99, 12, -99, 0, -99, -99, 0, -99, -99, 7, -99],
                arpPattern: [0, 1, 2, 3, 2, 1, 2, 1, 0, 1, 2, 3, 2, 1, 3, 2],
                kick: [0, 10], snare: [12],
                hat: [2, 6, 10, 14], openHat: [],
                denseHatBars: [], fillBars: [7, 15],
                leadDuty: 0.5, leadGain: 0.17,
                padGain: 0.10, crashBars: [0, 8])
        case .normal:
            // La minör, 132 BPM
            return MusicSpec(
                bpm: 132, bars: normalBars(),
                bassPattern: [0, -99, 0, -99, 12, -99, 0, -99, 0, -99, 0, -99, 12, -99, 7, -99],
                arpPattern: [0, 1, 2, 3, 2, 1, 2, 3, 0, 1, 2, 3, 2, 1, 3, 2],
                kick: [0, 8, 10], snare: [4, 12],
                hat: [0, 2, 4, 6, 8, 10, 12], openHat: [14],
                denseHatBars: Set(8..<16), fillBars: [7, 15],
                leadDuty: 0.25, leadGain: 0.20,
                padGain: 0.07, crashBars: [0, 8])
        case .normal2:
            // Si minör (+2 yarım ton), 150 BPM: ileri bölümlerde daha tempolu, kalın sesli versiyon
            return MusicSpec(
                bpm: 150, bars: normalBars(),
                bassPattern: [0, 0, -99, 0, 12, -99, 0, -99, 0, 0, -99, 0, 12, -99, 7, 12],
                arpPattern: [0, 1, 2, 3, 2, 1, 3, 2, 0, 1, 2, 3, 3, 2, 1, 2],
                kick: [0, 3, 8, 10, 14], snare: [4, 12],
                hat: [0, 2, 4, 6, 8, 10, 12, 14], openHat: [7, 15],
                denseHatBars: Set(4..<16), fillBars: [3, 7, 11, 15],
                leadDuty: 0.125, leadGain: 0.19,
                transpose: 2, padGain: 0.06, octaveGain: 0.25, crashBars: [0, 4, 8, 12])
        case .boss:
            // Mi minör, 172 BPM: saldırgan riff + yüksek melodi
            let em: (Int, [Int]) = (40, [52, 55, 59, 64])
            let c: (Int, [Int]) = (36, [48, 52, 55, 60])
            let d: (Int, [Int]) = (38, [50, 54, 57, 62])
            let b: (Int, [Int]) = (35, [47, 51, 54, 59])
            let bars: [MusicBar] = [
                // A bölümü: riff
                mbar(em.0, em.1, [76, 88, 76, 88, 76, 86, 76, 83]),
                mbar(c.0, c.1, [72, 84, 72, 84, 72, 83, 72, 79]),
                mbar(d.0, d.1, [74, 86, 74, 86, 74, 85, 74, 81]),
                mbar(b.0, b.1, [71, 83, 71, 83, 78, 83, 87, 83]),
                mbar(em.0, em.1, [76, 88, 76, 88, 76, 86, 76, 83]),
                mbar(c.0, c.1, [72, 84, 72, 84, 72, 83, 72, 79]),
                mbar(d.0, d.1, [74, 86, 74, 86, 74, 85, 74, 81]),
                mbar(b.0, b.1, [83, 0, 87, 0, 90, -1, 87, 83]),
                // B bölümü: melodi
                mbar(em.0, em.1, [88, -1, 86, -1, 83, 86, 88, -1]),
                mbar(c.0, c.1, [84, -1, 83, -1, 79, 83, 84, -1]),
                mbar(d.0, d.1, [86, -1, 85, -1, 81, 85, 86, -1]),
                mbar(b.0, b.1, [87, -1, 83, -1, 78, 83, 87, -1]),
                mbar(em.0, em.1, [88, 91, 88, 86, 83, 86, 88, 91]),
                mbar(c.0, c.1, [84, 88, 84, 83, 79, 83, 84, 88]),
                mbar(d.0, d.1, [86, 90, 86, 85, 81, 85, 86, 90]),
                mbar(b.0, b.1, [87, 0, 83, 0, 87, 90, 87, 83]),
            ]
            return MusicSpec(
                bpm: 172, bars: bars,
                bassPattern: [0, 0, 12, 0, 0, 0, 12, 0, 0, 0, 12, 0, 0, 12, 0, 12],
                arpPattern: [0, 2, 1, 3, 0, 2, 3, 1, 0, 2, 1, 3, 0, 3, 2, 1],
                kick: [0, 3, 6, 8, 11, 14], snare: [4, 12],
                hat: [], openHat: [],
                denseHatBars: Set(0..<16), fillBars: [7, 15],
                leadDuty: 0.125, leadGain: 0.18,
                octaveGain: 0.30, crashBars: [0, 8])
        case .bigBoss:
            // Re minör, 184 BPM: ağır bas, kalın oktavlı lead, her 4 ölçüde davul fillı
            let dm: (Int, [Int]) = (38, [50, 53, 57, 62])
            let bb: (Int, [Int]) = (34, [46, 50, 53, 58])
            let c: (Int, [Int]) = (36, [48, 52, 55, 60])
            let a: (Int, [Int]) = (33, [45, 49, 52, 57])
            let gm: (Int, [Int]) = (31, [43, 46, 50, 55])
            let eb: (Int, [Int]) = (39, [51, 55, 58, 63])
            let fm: (Int, [Int]) = (41, [53, 57, 60, 65])
            let bars: [MusicBar] = [
                // A bölümü: riff
                mbar(dm.0, dm.1, [74, 86, 74, 86, 74, 84, 74, 81]),
                mbar(dm.0, dm.1, [74, 86, 74, 86, 77, 84, 81, 77]),
                mbar(bb.0, bb.1, [70, 82, 70, 82, 70, 81, 70, 77]),
                mbar(c.0, c.1, [72, 84, 72, 84, 72, 82, 72, 79]),
                mbar(dm.0, dm.1, [74, 86, 74, 86, 74, 84, 74, 81]),
                mbar(dm.0, dm.1, [74, 86, 77, 86, 81, 86, 84, 81]),
                mbar(bb.0, bb.1, [82, -1, 79, 77, 82, -1, 86, 82]),
                mbar(a.0, a.1, [81, 85, 88, 85, 81, 85, 88, -1]),
                // B bölümü: melodi
                mbar(gm.0, gm.1, [86, -1, 82, -1, 79, 82, 86, -1]),
                mbar(gm.0, gm.1, [91, -1, 89, -1, 86, 89, 91, -1]),
                mbar(eb.0, eb.1, [87, -1, 84, -1, 79, 84, 87, -1]),
                mbar(fm.0, fm.1, [89, -1, 84, -1, 81, 84, 89, -1]),
                mbar(gm.0, gm.1, [86, 89, 91, 89, 86, 82, 79, 82]),
                mbar(eb.0, eb.1, [87, 91, 87, 84, 79, 84, 87, 91]),
                mbar(a.0, a.1, [88, 85, 81, 85, 88, 93, 88, 85]),
                mbar(a.0, a.1, [93, 0, 88, 0, 85, -1, -1, -1]),
            ]
            return MusicSpec(
                bpm: 184, bars: bars,
                bassPattern: [0, 0, 12, 0, 0, 0, 12, 0, 0, 12, 0, 0, 0, 12, 0, 7],
                arpPattern: [0, 2, 1, 3, 0, 2, 3, 1, 0, 2, 1, 3, 0, 3, 2, 1],
                kick: [0, 2, 3, 6, 8, 10, 11, 14], snare: [4, 12],
                hat: [], openHat: [15],
                denseHatBars: Set(0..<16), fillBars: [3, 7, 11, 15],
                leadDuty: 0.125, leadGain: 0.19,
                padGain: 0.05, octaveGain: 0.35, crashBars: [0, 4, 8, 12])
        }
    }

    private func synthMusic(_ track: Track) -> AVAudioPCMBuffer? {
        let spec = musicSpec(track)
        let sr = format.sampleRate
        let sps = Int(60.0 / spec.bpm / 4.0 * sr)          // bir 16'lık adımın örnek sayısı
        let total = spec.bars.count * 16 * sps
        guard total > 0, sps > 0,
              let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(total)),
              let ch = buf.floatChannelData?[0] else { return nil }
        buf.frameLength = AVAudioFrameCount(total)

        var lead = [Float](repeating: 0, count: total)
        var lead2 = [Float](repeating: 0, count: total)     // lead'in bir oktav altı
        var arp = [Float](repeating: 0, count: total)
        var bass = [Float](repeating: 0, count: total)
        var pad = [Float](repeating: 0, count: total)
        var drums = [Float](repeating: 0, count: total)
        var duck = [Float](repeating: 1, count: total)      // bas/arp/pad için kick "sidechain" düşüşü
        var rng: UInt32 = 0x9E3779B9

        func hz(_ m: Int) -> Double { 440.0 * pow(2.0, Double(m + spec.transpose - 69) / 12.0) }
        func noise() -> Float {
            rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5
            return Float(rng & 0xFFFF) / 32768.0 - 1.0
        }
        func wrap(_ i: Int) -> Int { i >= total ? i - total : i }

        let twoPi = 2.0 * Double.pi
        for barIndex in 0..<spec.bars.count {
            let b = spec.bars[barIndex]
            let isFill = spec.fillBars.contains(barIndex)
            let dense = spec.denseHatBars.contains(barIndex)
            let barStart = barIndex * 16 * sps

            // --- PAD (yumuşak üçgen akor, ölçü boyunca) ---
            if spec.padGain > 0 {
                let len = 16 * sps
                for n in 0..<3 {
                    let f = hz(b.arp[n])
                    var ph = 0.0
                    for k in 0..<len {
                        ph += f / sr; ph -= floor(ph)
                        let tri: Float = ph < 0.5 ? Float(4 * ph - 1) : Float(3 - 4 * ph)
                        let atk = min(1, Float(k) / Float(0.25 * sr))
                        let rel = min(1, Float(len - k) / Float(0.20 * sr))
                        pad[wrap(barStart + k)] += tri * atk * rel * 0.33
                    }
                }
            }

            // --- ZİL (bölüm başlarında) ---
            if spec.crashBars.contains(barIndex) {
                let len = Int(0.55 * sr)
                var prev: Float = 0
                for k in 0..<len {
                    let t = Double(k) / sr
                    let n = noise()
                    let hp = n - prev * 0.85
                    prev = n
                    drums[wrap(barStart + k)] += hp * Float(exp(-t * 6)) * 0.30
                }
            }

            for s in 0..<16 {
                let start = (barIndex * 16 + s) * sps

                // --- LEAD (vibratolu, PWM'li kare dalga + oktav altı ikizi) ---
                if s % 2 == 0 {
                    let slot = s / 2
                    let note = b.lead[slot]
                    if note > 0 {
                        var slots = 1
                        while slot + slots < 8 && b.lead[slot + slots] == -1 { slots += 1 }
                        let len = slots * 2 * sps
                        let f = hz(note)
                        var ph = 0.0
                        var ph2 = 0.0
                        let vibStart = Int(0.12 * sr)
                        let decayLen = Float(0.06 * sr)
                        for k in 0..<len {
                            let vib = k > vibStart ? 1.0 + 0.005 * sin(twoPi * 5.5 * Double(k) / sr) : 1.0
                            ph += f * vib / sr; ph -= floor(ph)
                            ph2 += f * 0.5 * vib / sr; ph2 -= floor(ph2)
                            let atk = min(1, Float(k) / 44)
                            let dec: Float = Float(k) < decayLen ? 1 - 0.25 * Float(k) / decayLen : 0.75
                            let rel = min(1, Float(len - k) / (0.18 * Float(len)))
                            let env = atk * dec * rel
                            // PWM: görev oranı yavaşça salınır, ses "canlı" durur
                            let sweep = 0.04 * sin(twoPi * 0.7 * Double(start + k) / sr)
                            let duty = min(0.5, max(0.08, spec.leadDuty + sweep))
                            let wave: Float = ph < duty ? 1 : -1
                            lead[wrap(start + k)] += wave * env
                            if spec.octaveGain > 0 {
                                let w2: Float = ph2 < 0.5 ? 1 : -1
                                lead2[wrap(start + k)] += w2 * env
                            }
                        }
                    }
                }

                // --- ARP (ince kare dalga) ---
                let ai = spec.arpPattern[s]
                if ai >= 0 {
                    let f = hz(b.arp[ai])
                    var ph = 0.0
                    for k in 0..<sps {
                        ph += f / sr; ph -= floor(ph)
                        let e = 1 - Float(k) / Float(sps)
                        let wave: Float = ph < 0.25 ? 1 : -1
                        arp[wrap(start + k)] += wave * e * e
                    }
                }

                // --- BAS (üçgen dalga) ---
                let off = spec.bassPattern[s]
                if off != -99 {
                    var steps = 1
                    while s + steps < 16 && spec.bassPattern[s + steps] == -99 { steps += 1 }
                    let len = steps * sps
                    let f = hz(b.bass + off)
                    var ph = 0.0
                    for k in 0..<len {
                        ph += f / sr; ph -= floor(ph)
                        let tri: Float = ph < 0.5 ? Float(4 * ph - 1) : Float(3 - 4 * ph)
                        let env = (1 - 0.3 * Float(k) / Float(len)) * min(1, Float(len - k) / (0.1 * Float(len)))
                        bass[wrap(start + k)] += tri * env
                    }
                }

                // --- DAVUL ---
                let fillHit = isFill && s >= 12
                if spec.kick.contains(s) && !fillHit {
                    var ph = 0.0
                    let len = Int(0.16 * sr)
                    for k in 0..<len {
                        let t = Double(k) / sr
                        ph += (42 + 120 * exp(-t * 30)) / sr
                        drums[wrap(start + k)] += Float(sin(twoPi * ph) * exp(-t * 14)) * 0.95
                    }
                    // Sidechain: kick vurunca bas / arp / pad kısa süre kısılır
                    let duckLen = Int(0.18 * sr)
                    for k in 0..<duckLen {
                        let idx = wrap(start + k)
                        let dv: Float = 0.30 + 0.70 * Float(k) / Float(duckLen)
                        if dv < duck[idx] { duck[idx] = dv }
                    }
                }
                if spec.snare.contains(s) || fillHit {
                    let gain: Float = fillHit ? 0.55 + 0.12 * Float(s - 12) : 0.85
                    let len = Int(0.13 * sr)
                    for k in 0..<len {
                        let t = Double(k) / sr
                        let n = noise() * Float(exp(-t * 28)) * 0.55
                        let tone = Float(sin(twoPi * 185 * t) * exp(-t * 45)) * 0.35
                        drums[wrap(start + k)] += (n + tone) * gain
                    }
                }
                let open = spec.openHat.contains(s)
                if open || spec.hat.contains(s) || dense {
                    let len = Int((open ? 0.14 : 0.035) * sr)
                    let decay: Double = open ? 18 : 110
                    var prev: Float = 0
                    for k in 0..<len {
                        let t = Double(k) / sr
                        let n = noise()
                        let hp = n - prev * 0.9
                        prev = n
                        drums[wrap(start + k)] += hp * Float(exp(-t * decay)) * (open ? 0.22 : 0.16)
                    }
                }
            }
        }

        // Karışım: lead'e noktalı sekizlik yankı (döngü başına sarmalı, dikişsiz) + yumuşak sınırlayıcı
        let d1 = sps * 3
        var out = [Float](repeating: 0, count: total)
        for i in 0..<total {
            var j1 = i - d1; if j1 < 0 { j1 += total }
            var j2 = i - 2 * d1; if j2 < 0 { j2 += total }
            let echo: Float = lead[i] + 0.32 * lead[j1] + 0.16 * lead[j2]
            let melody: Float = echo * spec.leadGain + lead2[i] * spec.octaveGain * spec.leadGain
            let body: Float = (arp[i] * 0.10 + bass[i] * 0.30 + pad[i] * spec.padGain) * duck[i]
            let v: Float = melody + body + drums[i] * 0.55
            out[i] = Float(tanh(Double(v) * 1.15)) * 0.92
        }
        for i in 0..<total { ch[i] = out[i] }
        return buf
    }

    func play(_ s: Sfx) {
        guard enabled, GameSettings.shared.sfxOn, let buf = buffers[s] else { return }
        if !engine.isRunning { try? engine.start() }
        let p = players[nextPlayer]
        nextPlayer = (nextPlayer + 1) % players.count
        p.scheduleBuffer(buf, at: nil, options: .interrupts, completionHandler: nil)
        if !p.isPlaying { p.play() }
    }

    private func synth(_ s: Sfx) -> AVAudioPCMBuffer? {
        let segs: [Seg]
        switch s {
        case .shoot:    segs = [Seg(f0: 1400, f1: 450, dur: 0.07, noise: false)]
        case .enemyHit:  segs = [Seg(f0: 0, f1: 0, dur: 0.14, noise: true)]
        case .bossHit:   segs = [Seg(f0: 240, f1: 180, dur: 0.05, noise: false)]
        case .playerHit: segs = [Seg(f0: 0, f1: 0, dur: 0.25, noise: true), Seg(f0: 300, f1: 60, dur: 0.35, noise: false)]
        case .stage:    segs = [Seg(f0: 523, f1: 523, dur: 0.09, noise: false),
                                Seg(f0: 659, f1: 659, dur: 0.09, noise: false),
                                Seg(f0: 784, f1: 784, dur: 0.09, noise: false),
                                Seg(f0: 1047, f1: 1047, dur: 0.18, noise: false)]
        case .gameOver:  segs = [Seg(f0: 392, f1: 392, dur: 0.2, noise: false),
                                Seg(f0: 330, f1: 330, dur: 0.2, noise: false),
                                Seg(f0: 262, f1: 262, dur: 0.2, noise: false),
                                Seg(f0: 196, f1: 180, dur: 0.45, noise: false)]
        case .blip:      segs = [Seg(f0: 880, f1: 880, dur: 0.04, noise: false)]
        case .heartPickup: segs = [Seg(f0: 440, f1: 880, dur: 0.12, noise: false)]
        case .powerUp:   segs = [Seg(f0: 300, f1: 1200, dur: 0.25, noise: false)]
        case .bomb:      segs = [Seg(f0: 0, f1: 0, dur: 0.30, noise: true),
                                Seg(f0: 700, f1: 50, dur: 0.45, noise: false)]
        case .shieldBreak: segs = [Seg(f0: 1000, f1: 250, dur: 0.16, noise: false),
                                   Seg(f0: 0, f1: 0, dur: 0.08, noise: true)]
        }
        let sr = format.sampleRate
        let total = segs.reduce(0) { $0 + Int($1.dur * sr) }
        guard total > 0,
              let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(total)),
              let channel = buf.floatChannelData?[0] else { return nil }
        buf.frameLength = AVAudioFrameCount(total)

        var i = 0
        var phase = 0.0
        var lfsr: UInt16 = 0xACE1
        var noiseVal: Float = 1
        var noiseClock = 0
        for seg in segs {
            let n = Int(seg.dur * sr)
            for k in 0..<n {
                let t = Double(k) / Double(max(n, 1))
                var v: Float
                if seg.noise {
                    noiseClock += 1
                    if noiseClock >= 4 {
                        noiseClock = 0
                        let bit = (lfsr ^ (lfsr >> 1)) & 1
                        lfsr = (lfsr >> 1) | (bit << 14)
                        noiseVal = (lfsr & 1) == 0 ? 1 : -1
                    }
                    v = noiseVal
                } else {
                    let f = seg.f0 + (seg.f1 - seg.f0) * t
                    phase += f / sr
                    phase -= floor(phase)
                    v = phase < 0.5 ? 1 : -1
                }
                let env = Float(1 - t)
                let level = (env * 15).rounded(.down) / 15
                channel[i] = v * level * 0.6
                i += 1
            }
        }
        return buf
    }
}

// MARK: - SaveStore
struct ScoreEntry: Codable {
    var isim: String
    var skor: Int
    var bolum: Int
    var kalanCan: Double
    var tarih: String
    var sureSn: Int
    var imha: Int
    var boss: Int
}

struct SaveFile: Codable {
    var surum: Int = 1
    var sonBasHarfler: String = "AAA"
    var oynananOyun: Int = 0
    var skorlar: [ScoreEntry] = []
}

final class SaveStore: @unchecked Sendable {
    static let shared = SaveStore()
    static let maxEntries = 100
    let fileURL: URL
    private(set) var data = SaveFile()

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("savegame.json")
        if FileManager.default.fileExists(atPath: fileURL.path) { reload() } else { save() }
    }

    func reload() {
        guard let raw = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(SaveFile.self, from: raw) else {
            data = SaveFile(); save(); return
        }
        data = decoded
    }

    @discardableResult
    func save() -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        guard let json = try? encoder.encode(data) else { return false }
        return (try? json.write(to: fileURL, options: .atomic)) != nil
    }

    var bestScore: Int { data.skorlar.first?.skor ?? 0 }
    var bestLevel: Int { data.skorlar.map(\.bolum).max() ?? 0 }
    var gamesPlayed: Int { data.oynananOyun }
    var lastInitials: String { data.sonBasHarfler }
    func top(_ n: Int) -> [ScoreEntry] { Array(data.skorlar.prefix(n)) }

    /// Mola'da kaydedilen geçici skoru siler (oyun bitince son skorla yeniden eklenir).
    func removeResult(tarih: String) {
        guard let i = data.skorlar.firstIndex(where: { $0.tarih == tarih }) else { return }
        data.skorlar.remove(at: i)
        data.oynananOyun = max(0, data.oynananOyun - 1)
        save()
    }

    func addResult(_ entry: ScoreEntry) {
        data.skorlar.append(entry)
        data.oynananOyun += 1
        data.sonBasHarfler = entry.isim
        data.skorlar.sort { $0.skor > $1.skor }
        save()
    }

    func resetAll() { data = SaveFile(); save() }
    func urlForSharing() -> URL { fileURL }

    /// Dışarıdan gelen kaydı güvenli hale getirir (uzunluk / değer sınırları).
    static func sanitized(_ f: SaveFile) -> SaveFile {
        func initials(_ t: String) -> String {
            let v = String(t.uppercased().filter { $0.isLetter }.prefix(3))
            return v.isEmpty ? "AAA" : v
        }
        var out = f
        out.skorlar = f.skorlar.prefix(1000).map { src in
            var e = src
            e.isim = initials(e.isim)
            e.skor = min(max(e.skor, 0), 999_999_999)
            e.bolum = min(max(e.bolum, 1), 999)
            e.kalanCan = min(max(e.kalanCan, 0), 9)
            e.sureSn = min(max(e.sureSn, 0), 999_999)
            e.imha = min(max(e.imha, 0), 999_999)
            e.boss = min(max(e.boss, 0), 999_999)
            e.tarih = String(e.tarih.prefix(40))
            return e
        }
        out.skorlar.sort { $0.skor > $1.skor }
        out.skorlar = Array(out.skorlar.prefix(maxEntries))
        out.sonBasHarfler = initials(f.sonBasHarfler)
        out.oynananOyun = min(max(f.oynananOyun, 0), 999_999)
        return out
    }

    /// Mevcut kaydı tamamen içe aktarılanla değiştirir.
    func replace(with file: SaveFile) {
        data = SaveStore.sanitized(file)
        save()
    }

    /// İçe aktarılan skorları mevcutlarla birleştirir (aynı kayıtlar tekrarlanmaz).
    func merge(_ file: SaveFile) {
        let incoming = SaveStore.sanitized(file)
        var all = data.skorlar
        for e in incoming.skorlar where !all.contains(where: {
            $0.isim == e.isim && $0.skor == e.skor && $0.bolum == e.bolum && $0.tarih == e.tarih
        }) { all.append(e) }
        all.sort { $0.skor > $1.skor }
        data.skorlar = Array(all.prefix(SaveStore.maxEntries))
        data.oynananOyun = max(data.oynananOyun, incoming.oynananOyun)
        save()
    }
}

// MARK: - Oyun Modelleri
struct IRect {
    var x: Int, y: Int, w: Int, h: Int
    func contains(_ p: CGPoint) -> Bool {
        p.x >= CGFloat(x) && p.x < CGFloat(x + w) && p.y >= CGFloat(y) && p.y < CGFloat(y + h)
    }
}

/// Zorluk ayarları: artık oyunun gerçekten her yerini etkiliyor.
enum Difficulty: String, CaseIterable {
    case kolay = "KOLAY"
    case normal = "NORMAL"
    case zor = "ZOR"

    /// Başlangıç canı
    var startLives: Double {
        switch self { case .kolay: return 6; case .normal: return 4; case .zor: return 3 }
    }
    /// Düşman hız çarpanı
    var enemySpeed: Double {
        switch self { case .kolay: return 0.55; case .normal: return 1.0; case .zor: return 1.6 }
    }
    /// Düşman ateş aralığı çarpanı (büyük = daha seyrek ateş)
    var fireInterval: Double {
        switch self { case .kolay: return 2.0; case .normal: return 1.15; case .zor: return 0.5 }
    }
    /// Düşman mermi hızı çarpanı
    var shotSpeed: Double {
        switch self { case .kolay: return 0.7; case .normal: return 0.95; case .zor: return 1.45 }
    }
    /// Boss canı çarpanı
    var bossHP: Double {
        switch self { case .kolay: return 0.5; case .normal: return 1.0; case .zor: return 2.2 }
    }
    /// Loot düşme şansı çarpanı
    var lootMul: Double {
        switch self { case .kolay: return 1.8; case .normal: return 1.1; case .zor: return 0.5 }
    }
    /// Skor çarpanı
    var scoreMul: Double {
        switch self { case .kolay: return 0.5; case .normal: return 1.0; case .zor: return 2.5 }
    }
    /// Bölümdeki düşman sayısı çarpanı
    var countMul: Double {
        switch self { case .kolay: return 0.6; case .normal: return 1.0; case .zor: return 1.5 }
    }
    /// Düşman başına ek can (zor modda herkes biraz daha dayanıklı)
    var extraEnemyHP: Int {
        switch self { case .kolay: return 0; case .normal: return 0; case .zor: return 2 }
    }
    /// Ekranda aynı anda bulunabilecek düşman mermisi sayısı (boss'lar hariç)
    var maxEnemyShots: Int {
        switch self { case .kolay: return 2; case .normal: return 5; case .zor: return 12 }
    }
    /// Alınan hasar çarpanı (gemi hasarıyla çarpılır, çeyrek kalbe yuvarlanır)
    var damageMul: Double {
        switch self { case .kolay: return 0.5; case .normal: return 1.0; case .zor: return 1.5 }
    }
    /// Can kaybından sonra dokunulmazlık süresi (kare)
    var respawnInvuln: Int {
        switch self { case .kolay: return 240; case .normal: return 180; case .zor: return 90 }
    }
    /// Oyuncunun atış bekleme süresi (kare)
    var fireCooldown: Int {
        switch self { case .kolay: return 8; case .normal: return 9; case .zor: return 10 }
    }
}

/// Özel yetenekler (5 gemide); ÖZEL düğmesiyle tetiklenir.
enum SpecialKind {
    case ghost, beam, nova, rage, repair, wing

    var name: String {
        switch self {
        case .ghost: return "HAYALET"
        case .beam: return "IŞIN TOPU"
        case .nova: return "NOVA"
        case .rage: return "ÇILGINLIK"
        case .repair: return "ONARIM"
        case .wing: return "FİLO"
        }
    }
    /// Bekleme süresi (kare, 60 kare = 1 sn)
    var cooldown: Int {
        switch self {
        case .ghost: return 20 * 60
        case .beam: return 25 * 60
        case .nova: return 25 * 60
        case .rage: return 25 * 60
        case .repair: return 40 * 60
        case .wing: return 30 * 60
        }
    }
    /// Seçim ekranı açıklaması (satır başına en fazla 18 karakter, 3'ün katı)
    var desc: [String] {
        switch self {
        case .ghost: return ["4 SANİYE BOYUNCA", "DOKUNULMAZ OLUR.", "MERMİ VE DÜŞMAN",
                             "İÇİNDEN GEÇER.", "BEKLEME: 20 SN.", ""]
        case .beam: return ["1,2 SANİYE DİKEY", "IŞIN ATAR. YOLDAKİ", "HER ŞEYE SÜREKLİ",
                            "HASAR VERİR VE", "MERMİLERİ SİLER.", "BEKLEME: 25 SN."]
        case .nova: return ["HER YÖNE 14 MERMİ", "FIRLATIR. MERMİLER", "İKİ KAT HASAR",
                            "VERİR. KALABALIĞI", "TEK SEFERDE SİLER.", "BEKLEME: 25 SN."]
        case .rage: return ["6 SANİYE BOYUNCA", "OTOMATİK VE ÇOK", "HIZLI ATEŞ EDER.",
                            "PARMAĞINI KALDIR,", "GEMİ ATEŞE DOYMAZ!", "BEKLEME: 25 SN."]
        case .repair: return ["ANINDA BİR CAN", "YENİLER VE 6 SN", "KALKAN AÇAR.",
                              "ZOR ANLARIN", "KURTARICISI.", "BEKLEME: 40 SN."]
        case .wing: return ["8 SANİYE BOYUNCA", "İKİ YARDIMCI GEMİ", "ÇAĞIRIR. İKİSİ DE", "SENİNLE BİRLİKTE", "ATEŞ EDER.", "BEKLEME: 30 SN."]
        }
    }
}

/// Seçilebilir gemiler (10 adet)
enum Ship: Int, CaseIterable {
    case sahin, yildirim, kale, nisanci, yelpaze, golge, topcu, dayanikli, ofke, komutan

    private struct Spec {
        let name: String
        let info: String
        let speed: Double
        let cooldownDelta: Int
        let livesDelta: Double
        let damage: Int
        let hitDamage: Double
        let shotSpeedMul: Double
        let spread: Double            // 0 = yok; > 0 = yan mermilerin yatay hızı (üç yönlü ateş)
        let speedStars: Int
        let fireStars: Int
        let lifeStars: Int
        let powerStars: Int
        let shotCore: UInt8
        let shotTrail: UInt8
        let desc: [String]            // uzun açıklama: satır başına en fazla 18 karakter
    }

    private static let specs: [Spec] = [
        Spec(name: "DENGELİ", info: "HER İŞE YARAR",
             speed: 2.0, cooldownDelta: 0, livesDelta: 0.0,
             damage: 1, hitDamage: 0.5, shotSpeedMul: 1.0, spread: 0.0,
             speedStars: 3, fireStars: 3, lifeStars: 3, powerStars: 2,
             shotCore: Pal.white, shotTrail: Pal.yellow,
             desc: [
                   "FİLONUN İLK GEMİSİ",
                   "HIZ, ATEŞ VE CAN",
                   "BİRBİRİNE EŞİT",
                   "OLDUĞU İÇİN HER",
                   "GÖREVDE İŞE YARAR.",
                   "YENİ BAŞLAYANLAR",
                   "İÇİN EN GÜVENLİ",
                   "SEÇİM. HATAYI",
                   "AFFEDEN GEMİ."
             ]),
        Spec(name: "HIZLI", info: "ÇEVİK, KIRILGAN",
             speed: 3.0, cooldownDelta: -3, livesDelta: 0.0,
             damage: 1, hitDamage: 0.75, shotSpeedMul: 1.0, spread: 0.0,
             speedStars: 5, fireStars: 5, lifeStars: 2, powerStars: 2,
             shotCore: Pal.white, shotTrail: Pal.cyan,
             desc: [
                   "İNCE GÖVDELİ AVCI.",
                   "ÇOK ÇEVİKTİR VE",
                   "MERMİLERİNİ ÇOK",
                   "ÇABUK ÇIKARIR.",
                   "DÜŞMAN DALGASINI",
                   "YAĞMUR GİBİ DELER.",
                   "AMA ZIRHI YOKTUR:",
                   "BİR DARBE TAM",
                   "BİR CAN ALIR.",
                   "KAÇMAYI BİL!"
             ]),
        Spec(name: "ZIRHLI", info: "SERT, YAVAŞ MERMİ",
             speed: 1.4, cooldownDelta: 3, livesDelta: 2.0,
             damage: 2, hitDamage: 0.25, shotSpeedMul: 0.5, spread: 0.0,
             speedStars: 2, fireStars: 2, lifeStars: 5, powerStars: 5,
             shotCore: Pal.yellow, shotTrail: Pal.orange,
             desc: [
                   "AĞIR ZIRHLI KALE",
                   "FİLONUN EN SERT",
                   "GEMİSİDİR. ÇEYREK",
                   "HASAR ALIR, İKİ",
                   "EKSTRA CANLA",
                   "BAŞLAR VE MERMİSİ",
                   "İKİ KAT VURUR.",
                   "BEDELİ: YAVAŞ",
                   "HAREKET VE YARI",
                   "HIZDA MERMİLER."
             ]),
        Spec(name: "NİŞANCI", info: "TEK ATIŞ ÇOK HASAR",
             speed: 1.8, cooldownDelta: 7, livesDelta: 0.0,
             damage: 3, hitDamage: 0.5, shotSpeedMul: 1.6, spread: 0.0,
             speedStars: 2, fireStars: 1, lifeStars: 3, powerStars: 4,
             shotCore: Pal.cyan, shotTrail: Pal.white,
             desc: [
                   "UZUN MENZİLLİ",
                   "KESKİN NİŞANCI.",
                   "AZ ATAR AMA HER",
                   "MERMİSİ ÜÇ HASAR",
                   "VERİR VE ÇOK HIZLI",
                   "GİDER. ATIŞ ARASI",
                   "UZUNDUR, BU YÜZDEN",
                   "HER ATIŞI SAY.",
                   "BOSS AVINDA",
                   "ÇOK ETKİLİDİR."
             ]),
        Spec(name: "YELPAZE", info: "ÜÇ YÖNLÜ ATEŞ",
             speed: 2.0, cooldownDelta: 2, livesDelta: 0.0,
             damage: 1, hitDamage: 0.5, shotSpeedMul: 1.0, spread: 1.1,
             speedStars: 3, fireStars: 3, lifeStars: 3, powerStars: 4,
             shotCore: Pal.pink, shotTrail: Pal.magenta,
             desc: [
                   "ÜÇ YÖNE BİRDEN",
                   "ATEŞ EDEN GEMİ.",
                   "ORTA MERMİ DÜZ,",
                   "YAN MERMİLER",
                   "ÇAPRAZ GİDER.",
                   "KALABALIK DÜŞMAN",
                   "SÜRÜLERİNİ TEK",
                   "BAŞINA TEMİZLER.",
                   "GÜCÜ ORTA, ALANI",
                   "GENİŞTİR."
             ]),
        Spec(name: "GÖLGE", info: "HAYALET HIZ",
             speed: 3.4, cooldownDelta: -2, livesDelta: -1.0,
             damage: 1, hitDamage: 0.75, shotSpeedMul: 1.3, spread: 0.0,
             speedStars: 5, fireStars: 4, lifeStars: 1, powerStars: 2,
             shotCore: Pal.white, shotTrail: Pal.purple,
             desc: [
                   "RADARA TAKILMAZ,",
                   "RÜZGAR GİBİ KAYAR.",
                   "EN YÜKSEK HIZA",
                   "VE HIZLI ATEŞE",
                   "SAHİPTİR, FAKAT",
                   "ZIRHI YOKTUR.",
                   "TEK DARBE BİR CAN",
                   "ALIR VE BİR CAN",
                   "EKSİK BAŞLAR.",
                   "USTALAR İÇİN!"
             ]),
        Spec(name: "TOPÇU", info: "AĞIR TOP, YAVAŞ",
             speed: 1.2, cooldownDelta: 12, livesDelta: 3.0,
             damage: 4, hitDamage: 0.25, shotSpeedMul: 0.7, spread: 0.0,
             speedStars: 1, fireStars: 1, lifeStars: 5, powerStars: 5,
             shotCore: Pal.yellow, shotTrail: Pal.red,
             desc: [
                   "SAVAŞ ALANININ",
                   "AĞIR TOPÇUSU.",
                   "HER MERMİSİ DÖRT",
                   "HASAR VERİR VE",
                   "BOSS CANINI HIZLA",
                   "ERİTİR. ATIŞ ARASI",
                   "ÇOK UZUN, GEMİ",
                   "ÇOK YAVAŞTIR.",
                   "ÜÇ EKSTRA CAN",
                   "İLE BAŞLAR."
             ]),
        Spec(name: "DAYANIKLI", info: "EN UZUN ÖMÜR",
             speed: 1.8, cooldownDelta: 1, livesDelta: 4.0,
             damage: 1, hitDamage: 0.5, shotSpeedMul: 1.0, spread: 0.0,
             speedStars: 2, fireStars: 3, lifeStars: 5, powerStars: 2,
             shotCore: Pal.lime, shotTrail: Pal.green,
             desc: [
                   "UZUN SAVAŞLAR İÇİN",
                   "TASARLANDI. DÖRT",
                   "EKSTRA CANLA",
                   "BAŞLAR VE KOLAY",
                   "KOLAY PES ETMEZ.",
                   "HIZI VE ATEŞİ",
                   "SIRADAN AMA CANI",
                   "BOL OLDUĞU İÇİN",
                   "HATAYA İZİN VERİR."
             ]),
        Spec(name: "ÖFKE", info: "ÇILGIN ATEŞ HIZI",
             speed: 2.6, cooldownDelta: -5, livesDelta: -1.0,
             damage: 1, hitDamage: 0.75, shotSpeedMul: 1.2, spread: 0.0,
             speedStars: 4, fireStars: 5, lifeStars: 1, powerStars: 3,
             shotCore: Pal.yellow, shotTrail: Pal.red,
             desc: [
                   "KONTROLSÜZ ÖFKE.",
                   "ÇILGIN ATEŞ HIZI",
                   "VE YÜKSEK SÜRAT",
                   "SUNAR, AMA ZIRHI",
                   "YOKTUR. BİR CAN",
                   "EKSİK BAŞLAR VE",
                   "HER DARBE TAM",
                   "CAN ALIR. SALDIR",
                   "VE KAÇMAYA BAK!"
             ]),
        Spec(name: "KOMUTAN", info: "ELİT, DENGELİ GÜÇ",
             speed: 2.2, cooldownDelta: 2, livesDelta: 1.0,
             damage: 2, hitDamage: 0.5, shotSpeedMul: 0.9, spread: 0.0,
             speedStars: 3, fireStars: 2, lifeStars: 4, powerStars: 4,
             shotCore: Pal.white, shotTrail: Pal.yellow,
             desc: [
                   "FİLO KOMUTANININ",
                   "KİŞİSEL GEMİSİ.",
                   "MERMİLERİ İKİ",
                   "HASAR VERİR, BİR",
                   "EKSTRA CANLA",
                   "BAŞLAR. HIZI VE",
                   "ZIRHI İYİDİR",
                   "AMA ATEŞ ARASI",
                   "BİRAZ UZUNDUR."
             ])
    ]

    private var spec: Spec { Ship.specs[rawValue] }

    var name: String { spec.name }
    var info: String { spec.info }
    /// Hareket hızı (piksel / kare)
    var speed: Double { spec.speed }
    /// Atış bekleme süresine eklenen kare (negatif = daha hızlı ateş)
    var cooldownDelta: Int { spec.cooldownDelta }
    /// Başlangıç canına eklenen / çıkarılan can
    var livesDelta: Double { spec.livesDelta }
    /// Mermi başına verilen hasar
    var damage: Int { spec.damage }
    /// Düşman mermisi / çarpışma başına kaybedilen can
    var hitDamage: Double { spec.hitDamage }
    /// Oyuncu mermisinin hız çarpanı
    var shotSpeedMul: Double { spec.shotSpeedMul }
    /// Yan mermilerin yatay hızı (0 = yan mermi yok)
    var spread: Double { spec.spread }
    /// Seçim ekranındaki çubuklar (1...5)
    var speedStars: Int { spec.speedStars }
    var fireStars: Int { spec.fireStars }
    var lifeStars: Int { spec.lifeStars }
    var powerStars: Int { spec.powerStars }
    /// Seçim ekranındaki uzun açıklama satırları
    var desc: [String] { spec.desc }
    var sprite: Sprite { Gfx.ships[rawValue] }
    var shotCore: UInt8 { spec.shotCore }
    var shotTrail: UInt8 { spec.shotTrail }
    /// Mermi kalınlığı (güçlü mermiler 2 piksel)
    var shotWidth: Int { damage >= 2 ? 2 : 1 }
    /// Özel yetenek (nil = yok). 20000 puan kilidi vardır.
    var special: SpecialKind? {
        switch self {
        case .golge: return .ghost
        case .topcu: return .beam
        case .yelpaze: return .nova
        case .ofke: return .rage
        case .dayanikli: return .repair
        case .komutan: return .wing
        default: return nil
        }
    }
}

enum EnemyKind {
    case drone, mech, boss, bigBoss
    var baseHP: Int {
        switch self { case .drone: return 1; case .mech: return 3; case .boss: return 30; case .bigBoss: return 60 }
    }
    var points: Int {
        switch self { case .drone: return 10; case .mech: return 25; case .boss: return 200; case .bigBoss: return 500 }
    }
    var frames: [Sprite] {
        switch self { case .drone: return Gfx.drone; case .mech: return Gfx.mech; case .boss, .bigBoss: return Gfx.boss }
    }
    var isBoss: Bool { self == .boss || self == .bigBoss }
    /// Çizim büyütme katı (Big Boss normal boss'un 2 katı)
    var scale: Int { self == .bigBoss ? 2 : 1 }
    var halfW: Double {
        switch self { case .boss: return 14; case .bigBoss: return 28; default: return 6 }
    }
    var halfH: Double {
        switch self { case .boss: return 10; case .bigBoss: return 20; default: return 6 }
    }
}

struct Enemy {
    let kind: EnemyKind
    var x: Double, y: Double, vx: Double, vy: Double
    var hp: Int, maxHP: Int, shootTimer: Int, flash = 0, phase = 0.0
    /// Bonus bölüm düşmanı: ateş etmez, zarar vermez, ekrandan çıkınca kaybolur
    var bonus = false

    init(kind: EnemyKind, x: Double, y: Double, vx: Double, vy: Double, hp: Int, shootTimer: Int) {
        self.kind = kind; self.x = x; self.y = y; self.vx = vx; self.vy = vy
        self.hp = hp; self.maxHP = hp; self.shootTimer = shootTimer
    }

    func overlaps(_ px: Double, _ py: Double, _ hw: Double, _ hh: Double) -> Bool {
        abs(px - x) <= kind.halfW + hw && abs(py - y) <= kind.halfH + hh
    }
}

struct PixelButton { let rect: IRect; let label: String; let color: UInt8 }
struct Shot { var x: Double, y: Double, vx: Double, vy: Double, power = 0 }
struct Boom { var x: Double, y: Double, big: Bool, t = 0 }
struct Star { var x: Double; var y: Double; let speed: Double; let color: UInt8; let blinkOffset: Int }
struct HeartDrop { var x: Double; var y: Double; var vy: Double }
struct ShieldPowerUp { var x: Double; var y: Double; var vy: Double }
/// BOMBA ÇEKİRDEĞİ: toplanınca ekranı temizler.
struct BombDrop { var x: Double; var y: Double; var vy: Double }

@MainActor
final class IslandController {
    private var activity: Activity<GalagaActivityAttributes>?
    func start(name: String, state: GalagaActivityAttributes.ContentState) {
        activity = try? Activity.request(attributes: GalagaActivityAttributes(oyuncu: name),
                                         content: ActivityContent(state: state, staleDate: nil), pushType: nil)
    }
    func update(_ state: GalagaActivityAttributes.ContentState) {
        Task { await activity?.update(ActivityContent(state: state, staleDate: nil)) }
    }
    func end() {
        Task { await activity?.end(nil, dismissalPolicy: .immediate) }
        activity = nil
    }
}

// MARK: - GameEngine (60 FPS Sabit Hız Mantığı)
@MainActor
final class GameEngine {
    enum State { case menu, shipSelect, scores, settings, stageIntro, playing, paused, gameOver, enterName }

    static let maxShieldLayers = 3
    /// Aynı anda atılan en fazla mermi sayısı.
    static let maxBullets = 4

    let fb = Framebuffer(width: Layout.width, height: Layout.fieldHeight + Layout.minPanelHeight)
    private let sound = RetroSound()
    private let haptic = RetroHaptic.shared
    private var state: State = .menu
    private var resumeState: State = .playing
    private var frame = 0
    private var difficulty: Difficulty = .normal

    private var tapLeft = false, tapRight = false, tapFire = false
    private var tapPause = false
    // Dokunmatik: alt paneldeki SOL / SAĞ / ATEŞ bölgeleri ve üstteki duraklatma düğmesi.
    private var touchLeft = false, touchRight = false, touchFire = false
    private var leftHeld: Bool { touchLeft }
    private var rightHeld: Bool { touchRight }
    private var fireHeld: Bool { touchFire }
    // Özel yetenek
    private var tapSpecial = false, touchSpecial = false
    private var specialCD = 0, beamTime = 0, rageTime = 0, wingTime = 0
    private static let specialUnlockScore = 20000
    private var specialUnlocked: Bool { GameSettings.shared.specialOpen || store.bestScore >= GameEngine.specialUnlockScore }
    private func isLocked(_ sh: Ship) -> Bool { sh.special != nil && !specialUnlocked }

    private var playerX = Double(Layout.width / 2)
    private var lives = 3.0
    private var invuln = 0, respawnTimer = 0, fireCooldown = 0
    private var enemies: [Enemy] = [], shots: [Shot] = [], enemyShots: [Shot] = []
    private var booms: [Boom] = [], stars: [Star] = [], hearts: [HeartDrop] = [], shields: [ShieldPowerUp] = []
    private var bombs: [BombDrop] = []
    /// Kalkan kalan süresi (kare). Her kapsül 15 sn ekler, en fazla 3 kapsül (45 sn) birikir.
    private var shieldTime = 0
    private static let shieldFramesPerCapsule = 15 * 60
    private var shieldLayers: Int { (shieldTime + GameEngine.shieldFramesPerCapsule - 1) / GameEngine.shieldFramesPerCapsule }
    private var shieldHitFlash = 0
    private static let shieldFlashMax = 8
    /// Tüm ekranı kaplayan yıldız alanı (oyun tuvalinden büyük, görünüm tarafından ayarlanır)
    private var starFB = Framebuffer(width: Layout.width, height: Layout.fieldHeight + Layout.minPanelHeight)
    private var bombFlash = 0
    /// Oyuncu gemisi boyutu: artık bölümle büyümüyor.
    private let playerSize = 16.0
    /// Aynı anda atılan mermi sayısı: her bölümde +1, oyuncu ölünce 1'e sıfırlanır.
    private var bulletCount = 1
    private var ship: Ship = .sahin
    private var selectedShip: Ship { Ship(rawValue: GameSettings.shared.shipIndex) ?? .sahin }
    // Kombo çarpanı: 5 öldürmede bir +1 (en fazla x5); 3 sn öldürme olmazsa veya hasar alınca sıfırlanır
    private var combo = 0, comboTimer = 0
    private static let comboWindow = 180
    private var comboMultiplier: Int { min(1 + combo / 5, 5) }
    // Bonus bölüm (7 bölümde bir)
    private var bonusKilled = 0, bonusTotal = 0
    private static let bonusEnemyCount = 40

    private var shakeFrames = 0, shakeIntensity = 0.0
    private var score = 0, level = 1, playFrames = 0, enemiesDefeated = 0, bossesFelled = 0
    private var toSpawn = 0, spawnTimer = 0, stateTimer = 0, bonusTimer = 0
    private var bonusText = ""
    private var menuIndex = 0, pauseIndex = 0, scoresIndex = 2, confirmIndex = 1, settingsIndex = 0
    private var confirmReset = false, toast = "", toastTimer = 0
    private var pauseSavedDate: String? = nil, pauseToast = "", pauseToastTimer = 0
    private var initials = [0, 0, 0], initialPos = 0
    private let store = SaveStore.shared
    private let island = IslandController()
    private var scoreList: [ScoreEntry] = []

    var onShare: ((URL) -> Void)?
    var onImportRequest: (() -> Void)?
    private var importPending: SaveFile?
    private var importIndex = 1

    private var menuButtons: [PixelButton] {
        [
            PixelButton(rect: IRect(x: 24, y: 154, w: 176, h: 22), label: "BAŞLA", color: Pal.lime),
            PixelButton(rect: IRect(x: 24, y: 180, w: 176, h: 22), label: "ZORLUK: \(difficulty.rawValue)", color: Pal.yellow),
            PixelButton(rect: IRect(x: 24, y: 206, w: 176, h: 22), label: "SKORLAR", color: Pal.cyan),
            PixelButton(rect: IRect(x: 24, y: 232, w: 176, h: 22), label: "AYARLAR", color: Pal.pink),
        ]
    }
    private var settingsButtons: [PixelButton] {
        let st = GameSettings.shared
        func onOff(_ b: Bool) -> String { b ? "AÇIK" : "KAPALI" }
        return [
            PixelButton(rect: IRect(x: 8, y: 62, w: 208, h: 24), label: "SES: " + onOff(st.sfxOn), color: st.sfxOn ? Pal.lime : Pal.gray),
            PixelButton(rect: IRect(x: 8, y: 90, w: 208, h: 24), label: "MÜZİK: " + onOff(st.musicOn), color: st.musicOn ? Pal.lime : Pal.gray),
            PixelButton(rect: IRect(x: 8, y: 118, w: 208, h: 24), label: "TİTREŞİM: " + onOff(st.hapticOn), color: st.hapticOn ? Pal.lime : Pal.gray),
            PixelButton(rect: IRect(x: 8, y: Self.sfxSliderY, w: 208, h: 34), label: "", color: Pal.cyan),
            PixelButton(rect: IRect(x: 8, y: Self.musicSliderY, w: 208, h: 34), label: "", color: Pal.orange),
            PixelButton(rect: IRect(x: 8, y: 226, w: 208, h: 22), label: "GERİ", color: Pal.yellow),
        ]
    }

    // Ses seviyesi kaydırıcıları (ayarlar ekranı)
    private static let sfxSliderY = 146, musicSliderY = 184
    private static let sliderX = 20, sliderW = 184

    /// Ayarlar: kaydırıcılara dokunma / sürükleme. Dokunulan satır seçilir, değer parmağın x konumuna ayarlanır.
    private func settingsSlide(_ points: [CGPoint], began: Bool) {
        guard state == .settings else { return }
        let st = GameSettings.shared
        for p in points {
            for (row, y) in [(3, Self.sfxSliderY), (4, Self.musicSliderY)] {
                guard p.x >= 8, p.x <= 216, p.y >= CGFloat(y), p.y < CGFloat(y + 34) else { continue }
                settingsIndex = row
                let raw = min(max((Double(p.x) - Double(Self.sliderX)) / Double(Self.sliderW), 0), 1)
                let v = (raw * 20).rounded() / 20
                if row == 3 {
                    guard v != st.sfxVolume else { continue }
                    st.sfxVolume = v; sound.applyVolumes()
                    if frame - lastSlideBlip > 8 { lastSlideBlip = frame; sound.play(.blip) }
                } else {
                    guard v != st.musicVolume else { continue }
                    st.musicVolume = v; sound.applyVolumes()
                }
            }
        }
    }
    private var lastSlideBlip = 0

    private let pauseButtons = [
        PixelButton(rect: IRect(x: 36, y: 116, w: 152, h: 22), label: "DEVAM", color: Pal.lime),
        PixelButton(rect: IRect(x: 36, y: 142, w: 152, h: 22), label: "SKORU KAYDET", color: Pal.cyan),
        PixelButton(rect: IRect(x: 36, y: 168, w: 152, h: 22), label: "ANA MENÜ", color: Pal.yellow),
    ]
    private let scoreButtons = [
        PixelButton(rect: IRect(x: 8, y: 214, w: 100, h: 24), label: "PAYLAŞ", color: Pal.cyan),
        PixelButton(rect: IRect(x: 116, y: 214, w: 100, h: 24), label: "YÜKLE", color: Pal.lime),
        PixelButton(rect: IRect(x: 8, y: 244, w: 100, h: 24), label: "SIFIRLA", color: Pal.red),
        PixelButton(rect: IRect(x: 116, y: 244, w: 100, h: 24), label: "ANA MENÜ", color: Pal.yellow),
    ]
    private let importButtons = [
        PixelButton(rect: IRect(x: 24, y: 138, w: 176, h: 22), label: "DEĞİŞTİR", color: Pal.red),
        PixelButton(rect: IRect(x: 24, y: 164, w: 176, h: 22), label: "BİRLEŞTİR", color: Pal.lime),
        PixelButton(rect: IRect(x: 24, y: 190, w: 176, h: 22), label: "İPTAL", color: Pal.yellow),
    ]
    private let confirmButtons = [
        PixelButton(rect: IRect(x: 32, y: 152, w: 72, h: 26), label: "EVET", color: Pal.red),
        PixelButton(rect: IRect(x: 120, y: 152, w: 72, h: 26), label: "HAYIR", color: Pal.lime),
    ]
    private static let letters = Array("ABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ")

    init() { makeStars() }

    private var panelTop: Int { Layout.fieldHeight }
    private var panelHeight: Int { fb.height - Layout.fieldHeight }

    func appDidBecomeActive() {
        sound.refreshMusic()
        store.reload()
        if state == .scores { scoreList = store.top(10) }
    }

    func appWillResignActive() {
        releaseInput()
        sound.setWanted(nil)
        if state == .playing || state == .stageIntro {
            resumeState = state
            pauseIndex = 0
            state = .paused
        }
        if state == .paused { island.update(islandState("MOLA")) }
    }

    func resize(canvasHeight: Int) { fb.resize(height: canvasHeight) }

    /// Basılı tutulan dokunuşları bırakır (uygulama arka plana giderken vb.)
    func releaseInput() {
        touchLeft = false; touchRight = false; touchFire = false; touchSpecial = false
    }

    /// Panel bölgesi: sol / sağ / ateş. Panelin dışındaki dokunuşlar yok sayılır.
    private func zone(_ p: CGPoint) -> (left: Bool, right: Bool, fire: Bool, special: Bool)? {
        guard p.y >= CGFloat(panelTop) else { return nil }
        if p.x < 57 { return (true, false, false, false) }
        if p.x < 112 { return (false, true, false, false) }
        if p.x < 132 { return (false, false, false, true) }
        return (false, false, true, false)
    }

    /// Duraklatma düğmesinin dokunma alanı (çizilen çerçeveden biraz geniş)
    private let pauseTouchRect = IRect(x: 88, y: 0, w: 48, h: 28)

    func touchesBegan(_ points: [CGPoint]) {
        settingsSlide(points, began: true)
        for p in points {
            if pauseTouchRect.contains(p) { tapPause = true; continue }
            guard let z = zone(p) else { continue }
            if z.left { tapLeft = true }
            if z.right { tapRight = true }
            if z.fire { tapFire = true }
            if z.special { tapSpecial = true }
        }
    }

    func setActiveTouches(_ points: [CGPoint]) {
        settingsSlide(points, began: false)
        touchLeft = false; touchRight = false; touchFire = false; touchSpecial = false
        for p in points {
            guard let z = zone(p) else { continue }
            if z.left { touchLeft = true }
            if z.right { touchRight = true }
            if z.fire { touchFire = true }
            if z.special { touchSpecial = true }
        }
    }

    private func islandState(_ status: String? = nil) -> GalagaActivityAttributes.ContentState {
        let bossAlive = enemies.contains { $0.kind.isBoss }
        return GalagaActivityAttributes.ContentState(skor: score, bolum: level, can: max(lives, 0),
                                                    durum: status ?? (bossAlive ? "BOSS!" : "OYUNDA"), bossVar: bossAlive)
    }

    private var accumulator: Double = 0.0
    /// 120 Hz ekranda iki çizim karesi arasındaki ilerleme (0...1): mantık 60 Hz, çizim her ekran karesinde
    private var renderAlpha = 0.0
    func updateWithDelta(_ dt: Double) {
        accumulator += min(dt, 0.2)
        while accumulator >= (1.0 / 60.0) {
            accumulator -= (1.0 / 60.0)
            tickEngine()
        }
        renderAlpha = state == .playing ? min(max(accumulator * 60.0, 0), 1) : 0
    }

    /// Çizim için oyuncunun ara konumu (basılı yöne göre ileri tahmin)
    private var renderPlayerX: Double {
        guard renderAlpha > 0, respawnTimer == 0, lives > 0 else { return playerX }
        let dir = ((rightHeld || tapRight) ? 1.0 : 0.0) - ((leftHeld || tapLeft) ? 1.0 : 0.0)
        let half = playerSize / 2.0
        return min(max(playerX + dir * ship.speed * renderAlpha, half), Double(Layout.width) - half)
    }

    private func tickEngine() {
        frame &+= 1
        if shakeFrames > 0 { shakeFrames -= 1 }
        if state != .paused { updateStars() }
        if bonusTimer > 0 && state != .paused { bonusTimer -= 1 }
        if state != .paused {
            if shieldHitFlash > 0 { shieldHitFlash -= 1 }
            if bombFlash > 0 { bombFlash -= 1 }
        }

        switch state {
        case .menu: updateMenu()
        case .shipSelect: updateShipSelect()
        case .scores: updateScores()
        case .settings: updateSettings()
        case .stageIntro:
            if checkPauseTap() { break }
            updatePlayerMovement(); updateBooms()
            stateTimer -= 1
            if stateTimer <= 0 { state = .playing }
        case .playing: updatePlaying()
        case .paused: updatePaused()
        case .gameOver:
            updateBooms()
            stateTimer -= 1
            if stateTimer <= 0 { beginNameEntry() }
        case .enterName: updateNameEntry()
        }
        if state == .playing || state == .stageIntro { island.update(islandState()) }
        sound.setWanted(desiredMusic())
        tapLeft = false; tapRight = false; tapFire = false; tapPause = false; tapSpecial = false
    }

    private func selectButtons(_ buttons: [PixelButton], index: inout Int) -> Bool {
        let n = buttons.count
        if tapLeft { index = (index + n - 1) % n; sound.play(.blip); haptic.tap() }
        if tapRight { index = (index + 1) % n; sound.play(.blip); haptic.tap() }
        return tapFire
    }

    private func updateMenu() {
        var idx = menuIndex
        let choose = selectButtons(menuButtons, index: &idx)
        menuIndex = idx
        guard choose else { return }
        haptic.success()
        if menuIndex == 0 {
            shipPick = GameSettings.shared.shipIndex
            descStartFrame = frame
            sound.play(.blip); state = .shipSelect
        } else if menuIndex == 1 {
            difficulty = difficulty == .kolay ? .normal : (difficulty == .normal ? .zor : .kolay)
            sound.play(.blip)
        } else if menuIndex == 2 {
            sound.play(.blip); openScores()
        } else {
            sound.play(.blip); openSettings()
        }
    }

    private var shipPick = 0
    private var descStartFrame = 0

    /// Gemi seçimi: < > ile gemiler (en sonda GERİ), ATEŞ ile onay
    private func updateShipSelect() {
        let n = Ship.allCases.count + 1
        if tapLeft { shipPick = (shipPick + n - 1) % n; descStartFrame = frame; sound.play(.blip); haptic.tap() }
        if tapRight { shipPick = (shipPick + 1) % n; descStartFrame = frame; sound.play(.blip); haptic.tap() }
        guard tapFire else { return }
        haptic.success()
        if shipPick >= Ship.allCases.count {
            sound.play(.blip); state = .menu
        } else if let sh = Ship(rawValue: shipPick), isLocked(sh) {
            sound.play(.shieldBreak); haptic.error()
        } else {
            GameSettings.shared.shipIndex = shipPick
            startGame()
        }
    }

    private func drawShipSelect() {
        let tx = (Layout.width - Framebuffer.textWidth("GEMİ SEÇ", scale: 2)) / 2
        fb.text("GEMİ SEÇ", tx + 2, 22, Pal.red, scale: 2)
        fb.text("GEMİ SEÇ", tx, 20, Pal.yellow, scale: 2)
        let ships = Ship.allCases

        // 5 x 2 gemi ızgarası
        for (i, sh) in ships.enumerated() {
            let cx = 24 + (i % 5) * 40
            let cy = 52 + (i / 5) * 30
            let sel = i == shipPick
            if sel { fb.rect(cx - 4, cy - 4, 24, 24, Pal.yellow) }
            fb.blit(sh.sprite, cx, cy + (sel ? (frame / 20) % 2 : 0))
            if isLocked(sh) { fb.dither(cx, cy, 16, 16, Pal.black) }
        }

        if shipPick < ships.count {
            let sh = ships[shipPick]
            let locked = isLocked(sh)
            fb.textCentered(sh.name, y: 104, Pal.white)
            fb.textCentered(sh.info, y: 117, Pal.gray)
            if let sp = sh.special { fb.textCentered("ÖZEL: " + sp.name, y: 130, locked ? Pal.dark : Pal.pink) }
            func bar(_ label: String, _ v: Int, _ y: Int, _ c: UInt8) {
                fb.text(label, 24, y, Pal.cyan)
                for k in 0..<5 { fb.fill(104 + k * 18, y, 14, 7, k < v ? c : Pal.gray) }
            }
            bar("HIZ", sh.speedStars, 145, Pal.lime)
            bar("ATEŞ", sh.fireStars, 157, Pal.yellow)
            bar("CAN", sh.lifeStars, 169, Pal.red)
            bar("GÜÇ", sh.powerStars, 181, Pal.orange)

            // Uzun açıklama (+ özel yetenek açıklaması): 3 satırlık sayfalar, her 2,5 saniyede bir değişir
            var lines = sh.desc
            while lines.count % 3 != 0 { lines.append("") }
            let specialStart = lines.count
            if let sp = sh.special { lines += sp.desc }
            let pages = max(1, (lines.count + 2) / 3)
            let page = ((frame - descStartFrame) / 150) % pages
            for k in 0..<3 {
                let idx = page * 3 + k
                if idx < lines.count { fb.textCentered(lines[idx], y: 195 + k * 12, idx >= specialStart ? Pal.pink : Pal.cyan) }
            }
            if pages > 1 {
                var dx = (Layout.width - (pages * 8 - 4)) / 2
                for p in 0..<pages {
                    fb.fill(dx, 232, 4, 4, p == page ? Pal.yellow : Pal.dark)
                    dx += 8
                }
            }
            if locked {
                fb.textCentered("KİLİTLİ 20000 PUAN", y: 244, Pal.red)
            } else if (frame / 24) % 2 == 0 { fb.textCentered("ATEŞ İLE BAŞLA", y: 244, Pal.orange) }
        } else {
            fb.textCentered("ANA MENÜYE DÖN", y: 150, Pal.yellow)
            if (frame / 24) % 2 == 0 { fb.textCentered("ATEŞ İLE ONAYLA", y: 244, Pal.orange) }
        }
        fb.textCentered("< > İLE SEÇ", y: 258, Pal.gray)
        fb.textCentered("GERİ", y: 272, shipPick >= ships.count ? Pal.yellow : Pal.dark)
    }

    private func openSettings() { settingsIndex = 0; state = .settings }

    private func updateSettings() {
        var idx = settingsIndex
        let choose = selectButtons(settingsButtons, index: &idx)
        settingsIndex = idx
        guard choose else { return }
        let st = GameSettings.shared
        switch settingsIndex {
        case 0: st.sfxOn.toggle(); sound.play(.blip)
        case 1: st.musicOn.toggle(); sound.refreshMusic()
        case 2: st.hapticOn.toggle()
        case 3:   // ATEŞ ile %25 artır (sona gelince başa dön)
            st.sfxVolume = st.sfxVolume >= 0.999 ? 0 : min(1, ((st.sfxVolume * 4).rounded() + 1) / 4)
            sound.applyVolumes(); sound.play(.blip)
        case 4:
            st.musicVolume = st.musicVolume >= 0.999 ? 0 : min(1, ((st.musicVolume * 4).rounded() + 1) / 4)
            sound.applyVolumes()
        default: sound.play(.blip); state = .menu
        }
        haptic.tap()
    }

    /// Duruma göre çalması gereken müzik parçası (nil = sessiz).
    private func desiredMusic() -> RetroSound.Track? {
        switch state {
        case .menu, .shipSelect, .scores, .settings: return .menu
        case .stageIntro, .playing:
            if enemies.contains(where: { $0.kind == .bigBoss }) { return .bigBoss }
            if enemies.contains(where: { $0.kind.isBoss }) { return .boss }
            return level >= 6 ? .normal2 : .normal
        case .paused, .gameOver, .enterName: return nil
        }
    }

    private func openScores() {
        scoreList = store.top(10)
        scoresIndex = 3; confirmReset = false; importPending = nil; toastTimer = 0; state = .scores
    }

    /// Seçilen kayıt dosyasını okur; geçerliyse "değiştir / birleştir / iptal" menüsünü açar.
    func importSave(from url: URL) {
        if let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize, size > 1_000_000 { failImport(); return }
        guard let raw = try? Data(contentsOf: url), raw.count <= 1_000_000,
              let decoded = try? JSONDecoder().decode(SaveFile.self, from: raw) else { failImport(); return }
        let clean = SaveStore.sanitized(decoded)
        guard !clean.skorlar.isEmpty || clean.oynananOyun > 0 else { failImport(); return }
        importPending = clean
        importIndex = 1
        confirmReset = false
        sound.play(.blip)
    }

    private func failImport() {
        toast = "GEÇERSİZ KAYIT"; toastTimer = 100
        sound.play(.playerHit); haptic.error()
    }

    private func updateImportConfirm() {
        var idx = importIndex
        let choose = selectButtons(importButtons, index: &idx)
        importIndex = idx
        guard choose, let pending = importPending else { return }
        importPending = nil
        switch importIndex {
        case 0:
            store.replace(with: pending); scoreList = store.top(10)
            toast = "KAYIT YÜKLENDİ"; toastTimer = 100
            sound.play(.powerUp); haptic.success()
        case 1:
            store.merge(pending); scoreList = store.top(10)
            toast = "BİRLEŞTİRİLDİ"; toastTimer = 100
            sound.play(.powerUp); haptic.success()
        default:
            sound.play(.blip); haptic.tap()
        }
    }

    private func updateScores() {
        if toastTimer > 0 { toastTimer -= 1 }
        if importPending != nil { updateImportConfirm(); return }
        if confirmReset {
            var idx = confirmIndex
            let choose = selectButtons(confirmButtons, index: &idx)
            confirmIndex = idx
            guard choose else { return }
            confirmReset = false
            if confirmIndex == 0 {
                store.resetAll(); scoreList = []
                // Özel yetenekli gemilerin kilidi de sıfırlanır; seçili gemi özel ise Dengeli'ye dön
                GameSettings.shared.specialOpen = false
                if Ship(rawValue: GameSettings.shared.shipIndex)?.special != nil { GameSettings.shared.shipIndex = 0 }
                toast = "SIFIRLANDI"; toastTimer = 100
                sound.play(.playerHit); haptic.error()
            } else { sound.play(.blip); haptic.tap() }
            return
        }
        var idx = scoresIndex
        let choose = selectButtons(scoreButtons, index: &idx)
        scoresIndex = idx
        guard choose else { return }
        sound.play(.blip); haptic.tap()
        if scoresIndex == 0 { onShare?(store.urlForSharing()) }
        else if scoresIndex == 1 { onImportRequest?() }
        else if scoresIndex == 2 { confirmReset = true; confirmIndex = 1 }
        else { state = .menu }
    }

    private func startGame() {
        ship = selectedShip
        playerX = Double(Layout.width / 2); lives = min(9.0, max(1, difficulty.startLives + ship.livesDelta))
        invuln = 0; respawnTimer = 0; fireCooldown = 0
        shieldTime = 0; shieldHitFlash = 0; bombFlash = 0
        specialCD = 300; beamTime = 0; rageTime = 0; wingTime = 0
        pauseSavedDate = nil; pauseToastTimer = 0
        enemies.removeAll(); shots.removeAll(); enemyShots.removeAll(); booms.removeAll()
        hearts.removeAll(); shields.removeAll(); bombs.removeAll()
        score = 0; level = 1; bulletCount = 1; combo = 0; comboTimer = 0; bonusKilled = 0; bonusTotal = 0; playFrames = 0; enemiesDefeated = 0; bossesFelled = 0; bonusTimer = 0
        beginStage()
        island.start(name: store.lastInitials, state: islandState())
    }

    /// Her 10 bölümde bir BIG BOSS (normal boss'un yerine geçer; 7'nin katı olan 70. bölümde de gelir).
    private var isBigBossStage: Bool { level % 10 == 0 }
    /// Her 7 bölümde bir BONUS bölüm (Big Boss bölümü hariç)
    private var isBonusStage: Bool { level % 7 == 0 && !isBigBossStage }
    private var isBossStage: Bool { (level % 2 == 0 || isBigBossStage) && !isBonusStage }
    /// Her 5 bölümde bir ELİT dalga: daha çok ve daha dayanıklı mech.
    private var isEliteStage: Bool { level % 5 == 0 && !isBonusStage }

    private func addScore(_ pts: Int, useCombo: Bool = false) {
        let mult = useCombo ? Double(comboMultiplier) : 1.0
        score += Int((Double(pts) * difficulty.scoreMul * mult).rounded())
    }

    /// Bonus bölüm sonu: vurulan düşman başına 100 puan, hepsi vurulduysa +5000.
    private func finishBonusStage() {
        let perfect = bonusKilled >= bonusTotal
        let reward = bonusKilled * 100 + (perfect ? 5000 : 0)
        addScore(reward)
        bonusText = perfect ? "MÜKEMMEL! +\(reward)" : "BONUS +\(reward)"
        bonusTimer = 160
        haptic.success()
    }

    /// Bonus bölüm düşmanı: dalga halinde sinüs yolunda uçar, ateş etmez.
    private func spawnBonus() {
        spawnTimer -= 1
        guard spawnTimer <= 0 else { return }
        let idx = bonusTotal - toSpawn
        toSpawn -= 1
        let wave = idx / 8, within = idx % 8
        spawnTimer = within == 7 ? 70 : 9
        let bases: [Double] = [56, 168, 112, 168, 56]
        let baseX = bases[min(wave, bases.count - 1)]
        var e = Enemy(kind: .drone, x: baseX, y: -10, vx: baseX, vy: 1.5, hp: 1, shootTimer: 1_000_000)
        e.bonus = true
        enemies.append(e)
    }

    private func beginStage() {
        shots.removeAll(); enemyShots.removeAll()   // kalp / kalkan / bomba yeni bölümde de kalır
        if isBonusStage {
            toSpawn = GameEngine.bonusEnemyCount; bonusTotal = toSpawn; bonusKilled = 0
        } else {
            toSpawn = isBossStage ? 6 : min(6 + level, 16) + min(max(0, (level - 10) / 3), 4)
            if isEliteStage { toSpawn += 4 }
            toSpawn = max(4, Int((Double(toSpawn) * difficulty.countMul).rounded()))
        }
        spawnTimer = 30
        if isBossStage {
            let normalHP = Double(EnemyKind.boss.baseHP + level * 2) * difficulty.bossHP
            if isBigBossStage {
                // Big Boss: normal boss'un 2 katı can
                let hp = Int((normalHP * 2.0).rounded())
                enemies.append(Enemy(kind: .bigBoss, x: Double(Layout.width / 2), y: -40, vx: 0, vy: 0,
                                     hp: max(hp, 10), shootTimer: Int(90.0 * difficulty.fireInterval)))
            } else {
                let hp = Int(normalHP.rounded())
                enemies.append(Enemy(kind: .boss, x: Double(Layout.width / 2), y: -20, vx: 0, vy: 0,
                                     hp: max(hp, 5), shootTimer: Int(90.0 * difficulty.fireInterval)))
            }
        }
        // Yeni bölümde 1,5 saniye dokunulmazlık (giriş ekranı bitince başlar)
        invuln = max(invuln, 90)
        stateTimer = 100; state = .stageIntro
        sound.play(.stage); haptic.success()
    }

    private func checkPauseTap() -> Bool {
        guard tapPause else { return false }
        resumeState = state; pauseIndex = 0; state = .paused
        sound.play(.blip); haptic.tap()
        return true
    }

    private func updatePlayerMovement() {
        guard respawnTimer == 0, lives > 0 else { return }
        if leftHeld || tapLeft { playerX -= ship.speed }
        if rightHeld || tapRight { playerX += ship.speed }
        let halfW = playerSize / 2.0
        playerX = min(max(playerX, halfW), Double(Layout.width) - halfW)
    }

    private func updatePlaying() {
        if checkPauseTap() { return }
        playFrames += 1; updatePlayerMovement()
        if invuln > 0 { invuln -= 1 }
        if shieldTime > 0 { shieldTime -= 1 }
        if comboTimer > 0 { comboTimer -= 1; if comboTimer == 0 { combo = 0 } }
        if fireCooldown > 0 { fireCooldown -= 1 }
        if specialCD > 0 { specialCD -= 1 }
        if rageTime > 0 { rageTime -= 1 }
        if wingTime > 0 { wingTime -= 1 }
        if !GameSettings.shared.specialOpen && score >= GameEngine.specialUnlockScore {
            GameSettings.shared.specialOpen = true
            bonusText = "ÖZEL AÇILDI!"; bonusTimer = 150
            sound.play(.powerUp); haptic.success()
        }

        if respawnTimer > 0 {
            respawnTimer -= 1
            if respawnTimer == 0 {
                if lives <= 0 {
                    island.end(); state = .gameOver; stateTimer = 160
                    sound.play(.gameOver); haptic.error()
                    return
                }
                playerX = Double(Layout.width / 2); invuln = difficulty.respawnInvuln
            }
        } else if (fireHeld || tapFire || rageTime > 0) && fireCooldown == 0 && shots.count < 120 {   // yalnızca güvenlik sınırı: ateş artık mermi ekrandan çıkana kadar beklemez
            fireBullets()
            fireCooldown = rageTime > 0 ? 3 : max(5, difficulty.fireCooldown + ship.cooldownDelta)
            sound.play(.shoot); haptic.shoot()
        }

        if tapSpecial { activateSpecial() }
        updateBeam()
        spawnWave(); updateEnemies(); updateShots(); updateHearts(); updateShields(); updateBombs()
        handleCollisions(); updateBooms()

        if toSpawn == 0 && enemies.isEmpty && respawnTimer == 0 && lives > 0 {
            if isBonusStage { finishBonusStage() }
            level += 1; bulletCount = min(bulletCount + 1, GameEngine.maxBullets); beginStage()
        }
    }

    private var wingOffsets: [Double] { [-20.0, 20.0] }

    private func activateSpecial() {
        guard let sp = ship.special, specialCD == 0, respawnTimer == 0, lives > 0, state == .playing else { return }
        specialCD = sp.cooldown
        switch sp {
        case .ghost:
            invuln = max(invuln, 240)
        case .beam:
            beamTime = 72
        case .nova:
            let n = 14
            for k in 0..<n {
                let a = Double(k) / Double(n) * 2.0 * Double.pi
                shots.append(Shot(x: playerX, y: Double(Layout.playerY + 8), vx: cos(a) * 2.6, vy: sin(a) * 2.6, power: 1))
            }
            shakeFrames = 12; shakeIntensity = 2.0
        case .rage:
            rageTime = 360
        case .wing:
            wingTime = 480
        case .repair:
            lives = min(lives + 1.0, 9.0)
            shieldTime = max(shieldTime, 360)
        }
        bonusText = sp.name + "!"; bonusTimer = 70
        sound.play(.powerUp); haptic.explode()
    }

    /// Topçu: dikey ışın; sütundaki düşmanlara sürekli hasar verir, mermileri siler.
    private func updateBeam() {
        guard beamTime > 0 else { return }
        beamTime -= 1
        guard respawnTimer == 0, lives > 0 else { beamTime = 0; return }
        if beamTime % 4 == 0 {
            for i in enemies.indices where enemies[i].hp > 0
                && abs(enemies[i].x - playerX) <= enemies[i].kind.halfW + 6
                && enemies[i].y < Double(Layout.playerY) {
                enemies[i].hp -= 2; enemies[i].flash = 3
                if enemies[i].hp <= 0 { registerKill(enemies[i], byBomb: false) }
            }
            enemies.removeAll { $0.hp <= 0 }
        }
        enemyShots.removeAll { abs($0.x - playerX) <= 7 }
    }

    private func fireBullets() {
        let startY = Double(Layout.playerY) - playerSize / 2.0
        let spacing = 6.0

        for i in 0..<bulletCount {
            let offset = (Double(i) - Double(bulletCount - 1) / 2.0) * spacing
            shots.append(Shot(x: playerX + offset, y: startY, vx: 0, vy: -5 * ship.shotSpeedMul))
        }
        // Komutan: yardımcı gemiler de ateş eder
        if wingTime > 0 {
            for dx in wingOffsets {
                shots.append(Shot(x: playerX + dx, y: startY + 4, vx: 0, vy: -5 * ship.shotSpeedMul))
            }
        }
        // Yelpaze: çapraz giden iki yan mermi
        if ship.spread > 0 {
            for dir in [-1.0, 1.0] {
                shots.append(Shot(x: playerX + dir * 5, y: startY + 2, vx: dir * ship.spread, vy: -5 * ship.shotSpeedMul))
            }
        }
    }

    private func spawnWave() {
        guard toSpawn > 0 else { return }
        if isBonusStage { spawnBonus(); return }
        spawnTimer -= 1
        guard spawnTimer <= 0 else { return }
        toSpawn -= 1; spawnTimer = max(24, 60 - level * 3)

        let elite = isEliteStage
        let mechChance = elite ? 0.85 : min(0.2 + Double(level) * 0.04, 0.6)
        let kind: EnemyKind = Double.random(in: 0..<1) < mechChance ? .mech : .drone

        // Bölüm bölüm kademeli zorlaşma: hız, ateş sıklığı, can
        let levelSpeed = min(1.0 + Double(level - 1) * 0.05, 2.2)
        let speedUp = levelSpeed * difficulty.enemySpeed
        let extraHP = max(0, (level - 6) / 3) + (elite ? 1 : 0) + difficulty.extraEnemyHP
        let fi = difficulty.fireInterval

        enemies.append(Enemy(kind: kind, x: Double.random(in: 16...Double(Layout.width - 16)), y: -10,
                             vx: Double.random(in: -0.7...0.7) * speedUp,
                             vy: (kind == .drone ? 0.45 : 0.35) * speedUp,
                             hp: kind.baseHP + extraHP,
                             shootTimer: Int.random(in: Int(60.0 * fi)...Int(160.0 * fi))))
    }

    private func updateEnemies() {
        let wrapY = Double(Layout.fieldHeight + 10), maxX = Double(Layout.width - 9)
        for i in enemies.indices {
            if enemies[i].flash > 0 { enemies[i].flash -= 1 }
            enemies[i].phase += enemies[i].kind.isBoss ? 0.02 * difficulty.enemySpeed : 0.02
            switch enemies[i].kind {
            case .boss:
                enemies[i].y = enemies[i].y < 70 ? enemies[i].y + 0.6 : 70 + sin(enemies[i].phase * 2) * 6
                enemies[i].x = Double(Layout.width / 2) + sin(enemies[i].phase) * 78
            case .bigBoss:
                enemies[i].y = enemies[i].y < 84 ? enemies[i].y + 0.6 : 84 + sin(enemies[i].phase * 2) * 6
                enemies[i].x = Double(Layout.width / 2) + sin(enemies[i].phase * 0.8) * 68
            case .drone, .mech:
                if enemies[i].bonus {
                    // vx = dalganın merkez x'i; sinüs yolunda aşağı iner
                    enemies[i].x = enemies[i].vx + sin(enemies[i].phase * 3.0) * 50
                    enemies[i].y += enemies[i].vy
                    continue
                }
                enemies[i].x += enemies[i].vx + sin(enemies[i].phase * 3) * 0.25
                enemies[i].y += enemies[i].vy
                if enemies[i].x < 9 || enemies[i].x > maxX {
                    enemies[i].vx = -enemies[i].vx
                    enemies[i].x = min(max(enemies[i].x, 9), maxX)
                }
                if enemies[i].y > wrapY { enemies[i].y = -10 }
            }
            enemies[i].shootTimer -= 1
            if enemies[i].shootTimer <= 0 { enemyFire(i) }
        }
        enemies.removeAll { $0.bonus && $0.y > Double(Layout.fieldBottom + 12) }
    }

    private func enemyFire(_ i: Int) {
        let e = enemies[i]
        guard e.y > 30, e.y < 210, respawnTimer == 0 else { enemies[i].shootTimer = 30; return }
        let fi = difficulty.fireInterval
        let speed = min((1.5 + Double(level) * 0.05) * difficulty.shotSpeed, 3.4 * difficulty.shotSpeed)
        if e.kind == .boss {
            for dx in [-8.0, 0.0, 8.0] {
                enemyShots.append(Shot(x: e.x + dx, y: e.y + 10, vx: 0, vy: speed))
            }
            enemies[i].shootTimer = Int(Double(max(30, 70 - level * 2)) * fi)
        } else if e.kind == .bigBoss {
            // Big Boss: yelpaze şeklinde 5 mermi
            let offsets = [-16.0, -8.0, 0.0, 8.0, 16.0]
            let spreads = [-0.8, -0.4, 0.0, 0.4, 0.8]
            for (dx, vx) in zip(offsets, spreads) {
                enemyShots.append(Shot(x: e.x + dx, y: e.y + 22, vx: vx, vy: speed))
            }
            enemies[i].shootTimer = Int(Double(max(50, 100 - level)) * fi)
        } else {
            if enemyShots.count >= difficulty.maxEnemyShots { enemies[i].shootTimer = 20; return }
            enemyShots.append(Shot(x: e.x, y: e.y + 6, vx: 0, vy: speed))
            let base = e.kind == .drone ? 170 : 140
            let lo = Int(Double(max(40, base - level * 6)) * fi)
            let hi = Int(Double(base + 50) * fi)
            enemies[i].shootTimer = Int.random(in: lo...max(lo, hi))
        }
    }

    private func updateShots() {
        for i in shots.indices {
            shots[i].x += shots[i].vx
            shots[i].y += shots[i].vy
        }
        shots.removeAll { $0.y < Double(Layout.hudTop) || $0.y > Double(Layout.fieldBottom + 10) || $0.x < 0 || $0.x > Double(Layout.width) }
        for i in enemyShots.indices {
            enemyShots[i].x += enemyShots[i].vx
            enemyShots[i].y += enemyShots[i].vy
        }
        enemyShots.removeAll { $0.y > Double(Layout.fieldBottom) || $0.x < -4 || $0.x > Double(Layout.width + 4) }
    }

    private func updateHearts() {
        for i in hearts.indices { hearts[i].y += hearts[i].vy }
        hearts.removeAll { $0.y > Double(Layout.fieldBottom) }
    }

    private func updateShields() {
        for i in shields.indices { shields[i].y += shields[i].vy }
        shields.removeAll { $0.y > Double(Layout.fieldBottom) }
    }

    private func updateBombs() {
        for i in bombs.indices { bombs[i].y += bombs[i].vy }
        bombs.removeAll { $0.y > Double(Layout.fieldBottom) }
    }

    /// Bir düşman öldüğünde puan, loot ve efekt işlemleri.
    private func registerKill(_ e: Enemy, byBomb: Bool) {
        addScore(e.kind.points, useCombo: true); enemiesDefeated += 1
        combo += 1; comboTimer = GameEngine.comboWindow
        if e.bonus { bonusKilled += 1 }
        if e.kind.isBoss {
            let big = e.kind == .bigBoss
            bossesFelled += 1; lives = min(lives + (big ? 2.0 : 1.0), 9.0)
            bonusText = big ? "BIG BOSS! +2 CAN" : "+1 CAN"; bonusTimer = 120
            sound.play(.stage); haptic.success()
            shakeFrames = big ? 40 : 20; shakeIntensity = big ? 5.0 : 3.5
            // Boss yenilince garanti bomba çekirdeği (Big Boss ayrıca kalkan da bırakır)
            // Aynı anda en fazla 1 bomba; normal boss %50, Big Boss garanti
            if !byBomb {
                if bombs.isEmpty && (big || Bool.random()) {
                    bombs.append(BombDrop(x: e.x + (big ? 16 : 0), y: e.y, vy: 0.7))
                }
                if big { shields.append(ShieldPowerUp(x: e.x - 16, y: e.y, vy: 0.7)) }
            }
        } else {
            sound.play(.enemyHit); haptic.hit()
            if !byBomb && !e.bonus { rollLoot(at: e) }
        }
        booms.append(Boom(x: e.x, y: e.y, big: e.kind.isBoss))
        if e.kind == .bigBoss {
            booms.append(Boom(x: e.x - 24, y: e.y, big: true))
            booms.append(Boom(x: e.x + 24, y: e.y, big: true))
        }
    }

    /// Loot tablosu (zorluk çarpanıyla ölçeklenir): kalp %12, kalkan %9, bomba %1,5 (ekranda en fazla 1)
    private func rollLoot(at e: Enemy) {
        let m = difficulty.lootMul
        let r = Double.random(in: 0..<1)
        let heartEnd = 0.12 * m
        let shieldEnd = heartEnd + 0.09 * m
        let bombEnd = shieldEnd + 0.015 * m
        if r < heartEnd {
            hearts.append(HeartDrop(x: e.x, y: e.y, vy: 0.8))
        } else if r < shieldEnd {
            shields.append(ShieldPowerUp(x: e.x, y: e.y, vy: 0.8))
        } else if r < bombEnd && bombs.isEmpty {
            bombs.append(BombDrop(x: e.x, y: e.y, vy: 0.7))
        }
    }

    /// Bomba: düşman mermilerini siler, drone'ları öldürür, mech'e 5 hasar, boss'a maksimum canının %15'i (Big Boss %10) kadar hasar verir.
    private func detonateBomb() {
        enemyShots.removeAll()
        bombFlash = 14
        shakeFrames = 30; shakeIntensity = 4.0
        sound.play(.bomb); haptic.explode()
        for i in enemies.indices {
            if enemies[i].kind == .drone {
                enemies[i].hp = 0
            } else if enemies[i].kind.isBoss {
                // Boss canı bölümle büyüdüğü için sabit 5 hasar fark edilmiyordu: maksimum canın %15'i (Big Boss %10)
                let pct = enemies[i].kind == .bigBoss ? 0.10 : 0.15
                enemies[i].hp -= max(5, Int((Double(enemies[i].maxHP) * pct).rounded()))
                enemies[i].flash = 8
            } else {
                enemies[i].hp -= 5
                enemies[i].flash = 8
            }
        }
        for e in enemies where e.hp <= 0 { registerKill(e, byBomb: true) }
        enemies.removeAll { $0.hp <= 0 }
    }

    private func handleCollisions() {
        var spent = Set<Int>()
        for (si, s) in shots.enumerated() {
            for ei in enemies.indices where enemies[ei].hp > 0 && enemies[ei].overlaps(s.x, s.y + 3, 1, 3) {
                spent.insert(si)
                enemies[ei].hp -= ship.damage + s.power; enemies[ei].flash = 4
                if enemies[ei].hp <= 0 {
                    registerKill(enemies[ei], byBomb: false)
                } else { sound.play(.bossHit); haptic.tap() }
                break
            }
        }
        if !spent.isEmpty { shots = shots.enumerated().filter { !spent.contains($0.offset) }.map { $0.element } }
        enemies.removeAll { $0.hp <= 0 }

        let px = playerX, py = Double(Layout.playerY + 9)
        hearts.removeAll { h in
            if abs(h.x - px) <= 12 && abs(h.y - py) <= 12 {
                addScore(100); lives = min(lives + 0.5, 9.0)
                sound.play(.heartPickup); haptic.success()
                return true
            }
            return false
        }

        // Kalkan kapsülü: her kapsül 15 sn ekler (en fazla 45 sn). Doluyken küçük puan verir.
        shields.removeAll { sh in
            if abs(sh.x - px) <= 14 && abs(sh.y - py) <= 14 {
                let maxFrames = GameEngine.maxShieldLayers * GameEngine.shieldFramesPerCapsule
                if shieldTime < maxFrames {
                    shieldTime = min(shieldTime + GameEngine.shieldFramesPerCapsule, maxFrames)
                    bonusText = "KALKAN \((shieldTime + 59) / 60) SN"
                } else {
                    addScore(50)
                    bonusText = "KALKAN MAKS +50"
                }
                bonusTimer = 70
                sound.play(.powerUp); haptic.success()
                return true
            }
            return false
        }

        // Bomba çekirdeği
        var bombCollected = false
        bombs.removeAll { b in
            if abs(b.x - px) <= 14 && abs(b.y - py) <= 14 {
                bombCollected = true
                return true
            }
            return false
        }
        if bombCollected {
            addScore(500)
            bonusText = "BOMBA! +500"; bonusTimer = 90
            detonateBomb()
        }

        guard respawnTimer == 0, lives > 0 else { return }

        // Kalkan aktifken her şey emilir: süre bitene kadar hasar yok
        if shieldTime > 0 {
            absorbWithShield(px: px, py: py)
            return
        }
        guard invuln == 0 else { return }
        var damage = 0.0
        if let idx = enemyShots.firstIndex(where: { abs($0.x - px) <= 8 && abs($0.y + 2 - py) <= 8 }) {
            enemyShots.remove(at: idx); damage = hitDamage(base: ship.hitDamage)
        } else if let ei = enemies.firstIndex(where: { !$0.bonus && $0.overlaps(px, py, 8, 8) }) {
            let isBoss = enemies[ei].kind.isBoss
            if !isBoss { booms.append(Boom(x: enemies[ei].x, y: enemies[ei].y, big: false)); enemies.remove(at: ei) }
            score = max(0, score - 50)
            damage = isBoss ? hitDamage(base: 0.75) : hitDamage(base: ship.hitDamage)
        }

        if damage > 0 {
            lives -= damage
            shakeFrames = 15; shakeIntensity = damage >= 1.0 ? 3.0 : 1.8
            killPlayer()
        }
    }

    /// Kalkan: gelen mermileri siler, çarpan düşmanları yok eder (boss'lar hariç), hasar almaz.
    /// Komutan'ın kalkanı geniştir: yardımcı askerleri de kapsar.
    private var shieldBaseRadius: Int { ship == .komutan ? 28 : Int(playerSize) / 2 + 4 }

    private func absorbWithShield(px: Double, py: Double) {
        let before = enemyShots.count
        let rr = Double(shieldBaseRadius)
        // 3 katmanlı kalkan mermiyi geri sektirir: yukarı giden, 2 hasarlı oyuncu mermisine dönüşür
        if shieldLayers >= GameEngine.maxShieldLayers {
            for sh in enemyShots where abs(sh.x - px) <= rr && abs(sh.y + 2 - py) <= rr {
                let speed = max(2.5, (sh.vx * sh.vx + sh.vy * sh.vy).squareRoot())
                let dx = sh.x - px, dy = min(sh.y - py, -1.0)   // kalkan merkezinden dışa
                let len = max((dx * dx + dy * dy).squareRoot(), 1.0)
                shots.append(Shot(x: sh.x, y: min(sh.y, py - 6), vx: dx / len * speed, vy: -abs(dy / len * speed), power: 1))
            }
        }
        enemyShots.removeAll { abs($0.x - px) <= rr && abs($0.y + 2 - py) <= rr }
        var hit = enemyShots.count != before
        for ei in enemies.indices.reversed() where enemies[ei].overlaps(px, py, rr - 2, rr - 2) && !enemies[ei].kind.isBoss {
            registerKill(enemies[ei], byBomb: true)
            enemies.remove(at: ei)
            hit = true
        }
        if hit && shieldHitFlash == 0 {
            shieldHitFlash = GameEngine.shieldFlashMax
            sound.play(.shieldBreak); haptic.hit()
        }
    }

    /// Alınan hasar: gemi hasarı x zorluk çarpanı, çeyrek kalbe yuvarlanır (0,25 - 1,0).
    private func hitDamage(base: Double) -> Double {
        min(max((base * difficulty.damageMul * 4).rounded() / 4, 0.25), 1.0)
    }

    private func killPlayer() {
        booms.append(Boom(x: playerX, y: Double(Layout.playerY + 8), big: true))
        enemyShots.removeAll(); respawnTimer = 100
        shieldTime = 0
        combo = 0; comboTimer = 0
        bulletCount = 1
        sound.play(.playerHit); haptic.explode()
    }

    private func updateBooms() {
        for i in booms.indices { booms[i].t += 1 }
        booms.removeAll { $0.t >= 18 }
    }

    private func updatePaused() {
        if pauseToastTimer > 0 { pauseToastTimer -= 1 }
        var idx = pauseIndex
        var choose = selectButtons(pauseButtons, index: &idx)
        pauseIndex = idx
        if tapPause { pauseIndex = 0; choose = true }
        guard choose else { return }
        sound.play(.blip); haptic.tap()
        if pauseIndex == 0 {
            state = resumeState
        } else if pauseIndex == 1 {
            savePausedScore()
        } else {
            island.end(); state = .menu
        }
    }

    /// Mola: o ana kadarki skoru skor tablosuna kaydeder (tekrar basılırsa güncel skorla yenilenir).
    private func savePausedScore() {
        guard score > 0 else { pauseToast = "SKOR YOK"; pauseToastTimer = 90; return }
        if let t = pauseSavedDate { store.removeResult(tarih: t) }
        let date = ISO8601DateFormatter().string(from: Date())
        let name = store.lastInitials.isEmpty ? "AAA" : store.lastInitials
        store.addResult(ScoreEntry(isim: name, skor: score, bolum: level, kalanCan: max(lives, 0), tarih: date,
                                   sureSn: playFrames / 60, imha: enemiesDefeated, boss: bossesFelled))
        pauseSavedDate = date
        pauseToast = "KAYDEDİLDİ!"; pauseToastTimer = 90
        sound.play(.powerUp); haptic.success()
    }

    private func beginNameEntry() {
        let last = store.lastInitials
        initials = last.prefix(3).map { ch in Self.letters.firstIndex(of: ch) ?? 0 }
        while initials.count < 3 { initials.append(0) }
        initialPos = 0; state = .enterName
    }

    private func updateNameEntry() {
        let n = Self.letters.count
        if tapLeft { initials[initialPos] = (initials[initialPos] + n - 1) % n; sound.play(.blip); haptic.tap() }
        if tapRight { initials[initialPos] = (initials[initialPos] + 1) % n; sound.play(.blip); haptic.tap() }
        guard tapFire else { return }
        sound.play(.shoot); haptic.success()
        initialPos += 1
        if initialPos >= 3 {
            if let t = pauseSavedDate { store.removeResult(tarih: t); pauseSavedDate = nil }
            store.addResult(ScoreEntry(isim: String(initials.map { Self.letters[$0] }), skor: score, bolum: level,
                                       kalanCan: max(lives, 0), tarih: ISO8601DateFormatter().string(from: Date()),
                                       sureSn: playFrames / 60, imha: enemiesDefeated, boss: bossesFelled))
            openScores()
        }
    }

    private func makeStars() {
        let w = starFB.width, h = starFB.height
        let count = max(56, w * h / 1150)
        let speed = 1.5 / 240.0
        stars = (0..<count).map { _ in
            Star(x: Double.random(in: 0..<Double(w)), y: Double.random(in: 0..<Double(h)),
                 speed: speed, color: Pal.white, blinkOffset: Int.random(in: 0..<64))
        }
    }

    private func updateStars() {
        let h = Double(starFB.height), w = Double(starFB.width)
        for i in stars.indices {
            stars[i].y += stars[i].speed
            if stars[i].y >= h { stars[i].y -= h; stars[i].x = Double.random(in: 0..<w) }
        }
    }

    /// Yıldız alanının piksel boyutunu ayarlar (görünümün tamamını kaplayacak kadar).
    func configureStars(cols: Int, rows: Int) {
        guard cols > 0, rows > 0, cols != starFB.width || rows != starFB.height else { return }
        starFB = Framebuffer(width: cols, height: rows)
        makeStars()
    }

    /// Arka plan yıldız katmanı (tüm ekran).
    func renderStarsImage() -> CGImage? {
        starFB.clear(Pal.black)
        for s in stars where ((frame + s.blinkOffset) / 8) % 4 != 0 {
            starFB.put(Int(s.x), Int(s.y), s.color)
        }
        return starFB.makeImage()
    }

    func renderImage() -> CGImage? { render(); return fb.makeImage() }

    private func two(_ n: Int) -> String { String(format: "%02d", min(max(n, 0), 99)) }
    private func six(_ n: Int) -> String { String(format: "%06d", min(max(n, 0), 999_999)) }

    private func render() {
        fb.clearTransparent()
        let ox = shakeFrames > 0 ? Int.random(in: Int(-shakeIntensity)...Int(shakeIntensity)) : 0
        let oy = shakeFrames > 0 ? Int.random(in: Int(-shakeIntensity)...Int(shakeIntensity)) : 0

        switch state {
        case .menu: drawMenu()
        case .shipSelect: drawShipSelect()
        case .scores: drawScores()
        case .settings: drawSettings()
        case .stageIntro, .playing, .paused, .gameOver:
            drawWorld(ox: ox, oy: oy)
            drawHUD()
            if bonusTimer > 0 && (state == .playing || state == .stageIntro) && (frame / 6) % 2 == 0 {
                fb.textCentered(bonusText, y: 110, Pal.lime)
            }
            if state == .stageIntro {
                fb.textCentered("BÖLÜM " + two(level), y: 132, Pal.cyan)
                if isBossStage && (frame / 12) % 2 == 0 {
                    fb.textCentered(isBigBossStage ? "BIG BOSS GELİYOR!" : "BOSS GELİYOR!", y: 152, Pal.red)
                }
                if isEliteStage && (frame / 12) % 2 == 1 { fb.textCentered("ELİT DALGA!", y: 172, Pal.orange) }
                if isBonusStage {
                    if (frame / 12) % 2 == 0 { fb.textCentered("BONUS BÖLÜM!", y: 152, Pal.lime) }
                    fb.textCentered("VURDUKÇA PUAN!", y: 172, Pal.yellow)
                }
            }
            if state == .gameOver {
                fb.textCentered("OYUN", y: 118, Pal.red, scale: 2)
                fb.textCentered("BİTTİ", y: 144, Pal.red, scale: 2)
            }
            if state == .paused { drawPause() }
        case .enterName: drawNameEntry()
        }
        drawPanel()
    }

    private func drawWorld(ox: Int, oy: Int) {
        let playerX = renderPlayerX   // ara kare konumu (120 Hz akıcılığı)
        let anim = (frame / 16) % 2
        for e in enemies {
            let spr = e.kind.frames[anim]
            let damaged = e.kind.isBoss && e.hp * 2 <= e.maxHP
            let cols: [UInt8]?
            if e.flash > 0 { cols = [Pal.white, Pal.white, Pal.white] }
            else if damaged { cols = [Pal.magenta, Pal.purple, Pal.yellow] }
            else if e.kind == .bigBoss { cols = [Pal.orange, Pal.red, Pal.white] }
            else { cols = nil }
            let sc = e.kind.scale
            let still = e.bonus || e.kind.isBoss
            let ex = e.x + (still ? 0 : e.vx * renderAlpha), ey = e.y + (still ? 0 : e.vy * renderAlpha)
            if sc > 1 {
                fb.blitScaledInt(spr, Int(ex) - spr.width * sc / 2 + ox, Int(ey) - spr.height * sc / 2 + oy, scale: sc, colors: cols)
            } else {
                fb.blit(spr, Int(ex) - spr.width / 2 + ox, Int(ey) - spr.height / 2 + oy, colors: cols)
            }
        }
        // Boss can çubuğu (normal boss ve Big Boss)
        for e in enemies where e.kind.isBoss && e.y > 40 {
            let barW = e.kind == .bigBoss ? 120 : 80, bx = (Layout.width - barW) / 2
            fb.rect(bx, 30, barW, 6, Pal.white)
            fb.fill(bx + 1, 31, Int(Double(barW - 2) * Double(max(e.hp, 0)) / Double(max(e.maxHP, 1))), 4, Pal.red)
        }
        for h in hearts { fb.blit(Gfx.heart, Int(h.x) - 4 + ox, Int(h.y + h.vy * renderAlpha) - 4 + oy) }

        // Kalkan kapsülü: nabız gibi atan, parlak yansımalı enerji küresi
        for sh in shields {
            let sx = Int(sh.x) + ox, sy = Int(sh.y + sh.vy * renderAlpha) + oy
            let pulse = (frame / 8) % 2
            fb.circle(sx, sy, 9 + pulse, pulse == 0 ? Pal.cyan : Pal.white, dithered: true)
            fb.disc(sx, sy, 7, Pal.navy)
            fb.disc(sx, sy, 6, Pal.blue)
            fb.disc(sx, sy, 5, Pal.cyan)
            fb.fill(sx - 1, sy - 3, 2, 6, Pal.blue)   // kalkan artı işareti
            fb.fill(sx - 3, sy - 1, 6, 2, Pal.blue)
            fb.fill(sx - 3, sy - 3, 2, 2, Pal.white)  // üst sol parlama
        }

        // BOMBA ÇEKİRDEĞİ: dönen yıldız, turuncu/magenta çekirdek
        for b in bombs {
            let bx = Int(b.x) + ox, by = Int(b.y + b.vy * renderAlpha) + oy
            if (frame / 6) % 2 == 0 {
                fb.fill(bx - 1, by - 10, 2, 4, Pal.yellow); fb.fill(bx - 1, by + 7, 2, 4, Pal.yellow)
                fb.fill(bx - 10, by - 1, 4, 2, Pal.yellow); fb.fill(bx + 7, by - 1, 4, 2, Pal.yellow)
            } else {
                for (dx, dy) in [(-8, -8), (8, -8), (-8, 8), (8, 8)] {
                    fb.fill(bx + dx - 1, by + dy - 1, 3, 3, Pal.yellow)
                }
            }
            fb.disc(bx, by, 6, Pal.orange)
            fb.disc(bx, by, 4, Pal.magenta)
            fb.disc(bx, by, 2, (frame / 4) % 2 == 0 ? Pal.yellow : Pal.white)
        }

        if respawnTimer == 0 && lives > 0 && (invuln == 0 || (frame / 4) % 2 == 0) {
            let size = Int(playerSize)
            let px = Int(playerX) + ox
            let py = Layout.playerY + oy
            fb.blit(ship.sprite, px - size / 2, py - size / 2 + 8)
        }

        // Katlanabilir enerji kalkanı: her katman ayrı renk, dönen parlak noktalar
        if respawnTimer == 0 && lives > 0 {
            let cx = Int(playerX) + ox
            let cy = Layout.playerY + 8 + oy
            let baseR = shieldBaseRadius
            // Son 3 saniyede kalkan yanıp söner
            let shieldBlinkOff = shieldTime < 180 && (frame / 5) % 2 == 0
            if shieldLayers > 0 && !shieldBlinkOff {
                for i in 0..<shieldLayers {
                    let r = baseR + i * 3
                    let col = shieldHitFlash > GameEngine.shieldFlashMax / 2 ? Pal.white : Pal.shieldLayerColors[i]
                    fb.circle(cx, cy, r, col)
                    fb.circle(cx, cy, r - 1, col, dithered: true)
                    let dir: Double = i % 2 == 0 ? 1.0 : -1.0
                    for k in 0..<3 {
                        let a = Double(frame) * 0.07 * dir + Double(k) * (2.0 * Double.pi / 3.0)
                        let dx = Int((Double(r) * cos(a)).rounded())
                        let dy = Int((Double(r) * sin(a)).rounded())
                        fb.fill(cx + dx - 1, cy + dy - 1, 2, 2, Pal.white)
                    }
                }
            }
            // Darbe alınca genişleyen kırılma halkası
            if shieldHitFlash > 0 {
                let r = baseR + (GameEngine.shieldFlashMax - shieldHitFlash) * 2
                fb.circle(cx, cy, r, Pal.white, dithered: shieldHitFlash < GameEngine.shieldFlashMax / 2)
            }
        }

        if beamTime > 0 && respawnTimer == 0 && lives > 0 {
            let bx = Int(playerX) + ox
            let top = Layout.hudTop + oy, bottom = Layout.playerY + oy
            let w = 6 + ((frame / 2) % 2) * 2
            fb.fill(bx - w / 2, top, w, bottom - top, ship.shotTrail)
            fb.fill(bx - 1, top, 2, bottom - top, Pal.white)
        }

        if wingTime > 0 && respawnTimer == 0 && lives > 0 && (wingTime > 120 || (frame / 5) % 2 == 0) {
            for dx in wingOffsets {
                let wx = min(max(Int(playerX + dx), 8), Layout.width - 8)
                fb.blit(Gfx.soldier, wx - 8 + ox, Layout.playerY + oy + 4 + ((frame / 10) % 2))
            }
        }

        let shotW = ship.shotWidth
        for s in shots {
            let x = Int(s.x + s.vx * renderAlpha) + ox, y = Int(s.y + s.vy * renderAlpha) + oy
            if s.power > 0 {
                fb.fill(x - 1, y - 1, 3, 3, ship.shotTrail); fb.fill(x, y, 1, 1, Pal.white)
                continue
            }
            fb.fill(x, y, shotW, 2, ship.shotCore); fb.fill(x, y + 2, shotW, 4, ship.shotTrail)
        }
        for s in enemyShots {
            let x = Int(s.x + s.vx * renderAlpha) + ox, y = Int(s.y + s.vy * renderAlpha) + oy
            // Düşman mermisi: macenta kapsül + sarı çekirdek (kalpten farklı renk ve şekil)
            fb.fill(x, y, 1, 5, Pal.magenta)
            fb.fill(x - 1, y + 1, 3, 3, Pal.magenta)
            fb.fill(x, y + 1, 1, 3, Pal.yellow)
        }
        for b in booms {
            let f = Gfx.explosion[min(b.t / 6, 2)]
            if b.big {
                for (dx, dy) in [(-9, -6), (9, -4), (0, 7)] { fb.blit(f, Int(b.x) + dx - 8 + ox, Int(b.y) + dy - 8 + oy) }
            } else { fb.blit(f, Int(b.x) - 8 + ox, Int(b.y) - 8 + oy) }
        }

        // Bomba patlaması: beyaz flaş + genişleyen şok dalgası
        if bombFlash > 0 {
            if bombFlash > 11 {
                fb.fill(0, 0, Layout.width, Layout.fieldHeight, Pal.white)
            } else if bombFlash > 6 {
                fb.dither(0, 0, Layout.width, Layout.fieldHeight, Pal.white)
            }
            let wr = (14 - bombFlash) * 16
            let wx = Int(playerX) + ox, wy = Layout.playerY + 8 + oy
            fb.circle(wx, wy, wr, Pal.orange)
            fb.circle(wx, wy, wr + 1, Pal.yellow)
            fb.circle(wx, wy, wr + 2, Pal.orange, dithered: true)
        }
    }

    private func drawHUD() {
        let isLowLife = lives <= 1.0
        let flashCan = !isLowLife || (frame / 15) % 2 == 0

        if (frame / 30) % 2 == 0 { fb.text("SKOR", 4, 1, Pal.red) }
        fb.text(six(score), 4, 13, Pal.white)
        fb.text("REKOR", Layout.width - 4 - Framebuffer.textWidth("REKOR"), 1, Pal.red)
        fb.text(six(max(score, store.bestScore)), Layout.width - 4 - 72, 13, Pal.white)
        if state == .playing || state == .stageIntro {
            fb.rect(102, 0, 20, 16, Pal.white)   // duraklatma düğmesi çerçevesi
            fb.blit(Gfx.pause, 108, 4)
        }

        if flashCan {
            // Görünen kalp = gerçek can: tam kalp + çeyrek hassasiyetinde kısmi kalp (en fazla 9 kalp)
            let q = max(Int((lives * 4).rounded()), 0)       // çeyrek kalp sayısı
            let fullHearts = q / 4, rem = q % 4
            for i in 0..<fullHearts {
                fb.blit(Gfx.heart, 4 + i * 10, Layout.fieldBottom + 3)
            }
            if rem > 0 {
                let x = 4 + fullHearts * 10
                fb.blit(Gfx.heart, x, Layout.fieldBottom + 3)
                let vis = rem * 2                              // 8 piksel genişliğin 1/4, 2/4, 3/4'ü
                fb.fill(x + vis, Layout.fieldBottom + 3, 8 - vis, 8, Pal.black)
            }
        }

        // Kalkan göstergesi (alt orta): renkli küre + kalan saniye
        if shieldTime > 0 {
            let secs = (shieldTime + 59) / 60
            let col = Pal.shieldLayerColors[max(0, shieldLayers - 1)]
            let cx = 96, cy = Layout.fieldBottom + 7
            fb.disc(cx, cy, 3, col)
            fb.put(cx - 1, cy - 1, Pal.white)
            let warn = shieldTime < 180 && (frame / 8) % 2 == 0
            fb.text(String(secs), 104, Layout.fieldBottom + 1, warn ? Pal.white : col)
        }

        fb.blit(Gfx.flag, Layout.width - 4 - 24 - 10, Layout.fieldBottom + 3)
        fb.text(two(level), Layout.width - 4 - 24, Layout.fieldBottom + 1, Pal.yellow)

        // Kombo çarpanı (sol üst) ve bonus bölüm sayacı (üst orta)
        if comboTimer > 0 && combo > 0 && (state == .playing || state == .stageIntro) {
            let m = comboMultiplier
            let col: UInt8 = m >= 5 ? Pal.red : (m >= 3 ? Pal.orange : (m >= 2 ? Pal.yellow : Pal.white))
            fb.text("X" + String(m), 4, 28, col)
            fb.fill(32, 33, max(1, 40 * comboTimer / GameEngine.comboWindow), 3, col)
        }
        if isBonusStage && (state == .playing || state == .stageIntro) {
            fb.textCentered("\(bonusKilled)/\(bonusTotal)", y: 30, Pal.cyan)
        }
    }

    private func drawBigButton(_ b: PixelButton, selected: Bool) {
        let r = b.rect
        if selected {
            fb.fill(r.x, r.y, r.w, r.h, b.color)
            fb.rect(r.x - 2, r.y - 2, r.w + 4, r.h + 4, Pal.white)
        } else {
            fb.fill(r.x, r.y, r.w, r.h, Pal.black)
            fb.rect(r.x, r.y, r.w, r.h, b.color)
            fb.rect(r.x + 1, r.y + 1, r.w - 2, r.h - 2, b.color)
        }
        let tw = Framebuffer.textWidth(b.label)
        let tx = r.x + (r.w - tw) / 2, ty = r.y + (r.h - 12) / 2
        fb.text(b.label, tx, ty, selected ? Pal.black : b.color)
        if selected && (frame / 16) % 2 == 0 { fb.text(">", tx - 16, ty, Pal.black) }
    }

    private func drawButtons(_ buttons: [PixelButton], selected: Int) {
        for (i, b) in buttons.enumerated() { drawBigButton(b, selected: i == selected) }
    }

    private func drawMenu() {
        let tx = (Layout.width - Framebuffer.textWidth("GALAGA", scale: 2)) / 2
        fb.text("GALAGA", tx + 2, 24, Pal.red, scale: 2)
        fb.text("GALAGA", tx, 22, Pal.yellow, scale: 2)
        fb.textCentered("RETRO ARCADE OYUN", y: 52, Pal.cyan)
        fb.textCentered("REKOR", y: 68, Pal.red)
        fb.textCentered(six(store.bestScore), y: 80, Pal.white)

        let anim = (frame / 16) % 2
        let table: [(Sprite, Int, Int)] = [(Gfx.drone[anim], EnemyKind.drone.points, 96),
                                           (Gfx.mech[anim], EnemyKind.mech.points, 114),
                                           (Gfx.boss[anim], EnemyKind.boss.points, 132)]
        for (spr, pts, y) in table {
            fb.blit(spr, 64 - spr.width / 2, y + 6 - spr.height / 2)
            fb.text(String(format: "%3d PUAN", pts), 88, y, Pal.white)
        }
        drawButtons(menuButtons, selected: menuIndex)
        if (frame / 24) % 2 == 0 {
            fb.textCentered("BAŞLAMAK İÇİN", y: 259, Pal.orange)
            fb.textCentered("ATEŞ TUŞUNA BASIN", y: 273, Pal.orange)
        }
    }

    private func drawSettings() {
        let tx = (Layout.width - Framebuffer.textWidth("AYARLAR", scale: 2)) / 2
        fb.text("AYARLAR", tx + 2, 32, Pal.red, scale: 2)
        fb.text("AYARLAR", tx, 30, Pal.yellow, scale: 2)
        drawButtons(settingsButtons, selected: settingsIndex)
        let st = GameSettings.shared
        let rows: [(Int, String, Double)] = [(3, "EFEKT SESİ", st.sfxVolume), (4, "MÜZİK SESİ", st.musicVolume)]
        for (idx, label, v) in rows {
            let b = settingsButtons[idx], sel = settingsIndex == idx
            let ink = sel ? Pal.black : b.color
            fb.text(label, b.rect.x + 8, b.rect.y + 4, ink)
            let num = String(Int((v * 100).rounded()))
            fb.text(num, b.rect.x + b.rect.w - 8 - Framebuffer.textWidth(num), b.rect.y + 4, ink)
            let bx = Self.sliderX, by = b.rect.y + 21
            fb.fill(bx, by, Self.sliderW, 6, sel ? Pal.black : Pal.dark)
            let filled = Int((Double(Self.sliderW) * v).rounded())
            fb.fill(bx, by, filled, 6, sel ? Pal.white : b.color)
            fb.fill(bx + filled - 2, by - 3, 4, 12, Pal.white)
        }
        fb.textCentered(settingsIndex == 3 || settingsIndex == 4 ? "SÜRÜKLE VEYA ATEŞ" : "< > İLE SEÇ", y: 254, Pal.gray)
        fb.textCentered("ATEŞ İLE ONAYLA", y: 268, Pal.gray)
    }

    private func drawScores() {
        fb.textCentered("EN İYİ SKORLAR", y: 20, Pal.red)
        if scoreList.isEmpty { fb.textCentered("HENÜZ SKOR YOK", y: 110, Pal.gray) }
        for (i, s) in scoreList.prefix(10).enumerated() {
            let name = String(s.isim.prefix(3)).padding(toLength: 3, withPad: " ", startingAt: 0)
            let line = two(i + 1) + " " + name + " " + six(s.skor) + " " + two(s.bolum)
            fb.text(line, 16, 42 + i * 16, i == 0 ? Pal.yellow : (i < 3 ? Pal.white : Pal.cyan))
        }
        drawButtons(scoreButtons, selected: (confirmReset || importPending != nil) ? -1 : scoresIndex)

        if let pending = importPending {
            fb.dither(0, 0, Layout.width, Layout.fieldHeight, Pal.black)
            let box = IRect(x: 8, y: 60, w: 208, h: 166)
            fb.fill(box.x, box.y, box.w, box.h, Pal.black)
            fb.rect(box.x, box.y, box.w, box.h, Pal.white); fb.rect(box.x + 2, box.y + 2, box.w - 4, box.h - 4, Pal.lime)
            fb.textCentered("KAYIT BULUNDU", y: 70, Pal.yellow)
            fb.textCentered("SKOR: " + String(pending.skorlar.count), y: 90, Pal.white)
            fb.textCentered("REKOR: " + six(pending.skorlar.first?.skor ?? 0), y: 104, Pal.cyan)
            fb.textCentered("OYUN: " + String(pending.oynananOyun), y: 118, Pal.white)
            drawButtons(importButtons, selected: importIndex)
        } else if confirmReset {
            fb.dither(0, 0, Layout.width, Layout.fieldHeight, Pal.black)
            let box = IRect(x: 16, y: 88, w: 192, h: 108)
            fb.fill(box.x, box.y, box.w, box.h, Pal.black)
            fb.rect(box.x, box.y, box.w, box.h, Pal.white); fb.rect(box.x + 2, box.y + 2, box.w - 4, box.h - 4, Pal.red)
            fb.textCentered("EMİN MİSİN?", y: 100, Pal.yellow)
            fb.textCentered("HEPSİ SİLİNECEK", y: 120, Pal.red)
            drawButtons(confirmButtons, selected: confirmIndex)
        } else if toastTimer > 0 {
            let w = Framebuffer.textWidth(toast) + 24
            let box = IRect(x: (Layout.width - w) / 2, y: 104, w: w, h: 28)
            fb.fill(box.x, box.y, box.w, box.h, Pal.black); fb.rect(box.x, box.y, box.w, box.h, Pal.yellow)
            fb.textCentered(toast, y: box.y + 8, Pal.yellow)
        }
    }

    private func drawPause() {
        fb.dither(0, 0, Layout.width, Layout.fieldHeight, Pal.black)
        let box = IRect(x: 24, y: 88, w: 176, h: 112)
        fb.fill(box.x, box.y, box.w, box.h, Pal.black)
        fb.rect(box.x, box.y, box.w, box.h, Pal.white); fb.rect(box.x + 2, box.y + 2, box.w - 4, box.h - 4, Pal.blue)
        if pauseToastTimer > 0 { fb.textCentered(pauseToast, y: 98, Pal.lime) } else { fb.textCentered("MOLA", y: 98, Pal.yellow) }
        drawButtons(pauseButtons, selected: pauseIndex)
    }

    private func drawNameEntry() {
        fb.textCentered("OYUN", y: 12, Pal.red, scale: 2)
        fb.textCentered("BİTTİ", y: 38, Pal.red, scale: 2)
        let t = playFrames / 60
        let stats = [("SKOR", six(score), Pal.white), ("BÖLÜM", two(level), Pal.yellow),
                     ("SÜRE", String(format: "%02d:%02d", (t / 60) % 100, t % 60), Pal.cyan),
                     ("İMHA", String(format: "%04d", min(enemiesDefeated, 9999)), Pal.lime), ("BOSS", two(bossesFelled), Pal.pink)]
        for (i, row) in stats.enumerated() {
            let y = 72 + i * 16
            fb.text(row.0, 24, y, Pal.gray)
            fb.text(row.1, Layout.width - 24 - Framebuffer.textWidth(row.1), y, row.2)
        }
        fb.textCentered("ADINI GİR", y: 160, Pal.cyan)
        for i in 0..<3 {
            let x = 68 + i * 32, ch = String(Self.letters[initials[i]])
            if i == initialPos {
                if (frame / 10) % 3 != 0 { fb.text(ch, x, 180, Pal.yellow, scale: 2) }
                fb.fill(x, 206, 24, 2, Pal.yellow)
            } else { fb.text(ch, x, 180, i < initialPos ? Pal.white : Pal.gray, scale: 2) }
        }
        fb.textCentered("<> HARF ATEŞ ONAY", y: 226, Pal.gray)
    }

    private func drawPanel() {
        drawButton(IRect(x: 4, y: panelTop + 6, w: 50, h: panelHeight - 12), "<", pressed: leftHeld)
        drawButton(IRect(x: 60, y: panelTop + 6, w: 50, h: panelHeight - 12), ">", pressed: rightHeld)
        drawButton(IRect(x: 136, y: panelTop + 6, w: 84, h: panelHeight - 12), "ATEŞ", pressed: fireHeld)
        drawSpecialButton(IRect(x: 113, y: panelTop + 6, w: 20, h: panelHeight - 12))
    }

    /// Küçük ÖZEL düğmesi: < > ile ATEŞ arasındaki boşlukta. Bekleme süresince aşağıdan dolar.
    private func drawSpecialButton(_ r: IRect) {
        // Menü, skor ve ayar ekranlarında önceki oyunun doluşu görünmesin
        let inGame = state == .stageIntro || state == .playing || state == .paused || state == .gameOver
        guard inGame, let sp = ship.special else {
            fb.rect(r.x, r.y, r.w, r.h, Pal.dark)
            fb.text("-", r.x + (r.w - Framebuffer.textWidth("-")) / 2, r.y + (r.h - 12) / 2, Pal.dark)
            return
        }
        let ready = specialCD == 0
        let pressed = touchSpecial && ready
        if pressed { fb.fill(r.x, r.y, r.w, r.h, Pal.white) }
        if !ready {
            let inner = r.h - 4
            let h = inner * (sp.cooldown - specialCD) / max(1, sp.cooldown)
            fb.fill(r.x + 2, r.y + r.h - 2 - h, r.w - 4, h, Pal.dark)
        }
        let border = ready ? ((frame / 12) % 2 == 0 ? Pal.yellow : Pal.white) : Pal.gray
        fb.rect(r.x, r.y, r.w, r.h, border)
        fb.text("Ö", r.x + (r.w - Framebuffer.textWidth("Ö")) / 2, r.y + (r.h - 12) / 2,
                pressed ? Pal.black : (ready ? Pal.yellow : Pal.gray))
    }

    private func drawButton(_ r: IRect, _ label: String, pressed: Bool) {
        if pressed { fb.fill(r.x, r.y, r.w, r.h, Pal.white) }
        fb.rect(r.x, r.y, r.w, r.h, Pal.white)
        fb.rect(r.x + 2, r.y + 2, r.w - 4, r.h - 4, pressed ? Pal.black : Pal.gray)
        fb.text(label, r.x + (r.w - Framebuffer.textWidth(label)) / 2, r.y + (r.h - 12) / 2, pressed ? Pal.black : Pal.white)
    }
}

// MARK: - GameScreenView (120 Hz Ekran / 60 FPS Mantık Bağlantısı)
final class GameScreenView: UIView {
    private let engine: GameEngine
    private let starLayer = CALayer()
    private let screenLayer = CALayer()
    private let scanLayer = CALayer()
    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var pointsPerPixel: CGFloat = 1
    private var scanKey = (rows: 0, k: 0)

    override init(frame: CGRect) {
        engine = GameEngine()
        super.init(frame: frame)
        backgroundColor = .black; isMultipleTouchEnabled = true
        for l in [starLayer, screenLayer, scanLayer] {
            l.magnificationFilter = .nearest; l.minificationFilter = .nearest
            l.actions = ["contents": NSNull(), "bounds": NSNull(), "position": NSNull()]
            layer.addSublayer(l)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        engine.onShare = { [weak self] url in self?.presentShare(url) }
        engine.onImportRequest = { [weak self] in self?.presentImportPicker() }
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func resignActive() { engine.appWillResignActive() }
    @objc private func becomeActive() { engine.appDidBecomeActive() }

    private func presentShare(_ url: URL) {
        guard var top = window?.rootViewController else { return }
        while let presented = top.presentedViewController { top = presented }
        activeTouches.removeAll(); engine.releaseInput()
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let pop = vc.popoverPresentationController {
            pop.sourceView = self; pop.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY - 80, width: 1, height: 1)
        }
        top.present(vc, animated: true)
    }

    private func presentImportPicker() {
        guard var top = window?.rootViewController else { return }
        while let presented = top.presentedViewController { top = presented }
        activeTouches.removeAll(); engine.releaseInput()
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json, .plainText], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        top.present(picker, animated: true)
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            guard link == nil else { return }
            let l = CADisplayLink(target: self, selector: #selector(tick(_:)))
            l.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
            l.add(to: .main, forMode: .common)
            link = l; lastTimestamp = 0
        } else {
            link?.invalidate(); link = nil
        }
    }

    @objc private func tick(_ l: CADisplayLink) {
        let dt = lastTimestamp == 0 ? (1.0 / 120.0) : (l.timestamp - lastTimestamp)
        lastTimestamp = l.timestamp
        engine.updateWithDelta(dt)
        starLayer.contents = engine.renderStarsImage()
        screenLayer.contents = engine.renderImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }
        let ds = max(1, traitCollection.displayScale)
        var k = max(1, Int((bounds.width * ds) / CGFloat(Layout.width)))
        func canvasHeight(_ k: Int) -> Int { Int((bounds.height * ds) / CGFloat(k)) }
        let minH = Layout.fieldHeight + Layout.minPanelHeight
        while k > 1 && canvasHeight(k) < minH { k -= 1 }
        let h = max(minH, min(canvasHeight(k), Layout.fieldHeight + Layout.maxPanelHeight))
        engine.resize(canvasHeight: h)

        pointsPerPixel = CGFloat(k) / ds
        let w = CGFloat(Layout.width) * pointsPerPixel, hh = CGFloat(h) * pointsPerPixel
        let x = (((bounds.width - w) / 2) * ds).rounded() / ds
        let y = (((bounds.height - hh) / 2) * ds).rounded() / ds
        let frame = CGRect(x: x, y: y, width: w, height: hh)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        screenLayer.frame = frame; scanLayer.frame = frame
        if scanKey.rows != h || scanKey.k != k {
            scanKey = (h, k); scanLayer.contents = makeScanlines(rows: h, k: k)
        }

        // Yıldız alanı: oyun tuvalinin dışındaki siyah şeritler dahil tüm ekranı kaplar
        let kf = CGFloat(k)
        let left = max(0, Int(ceil(x * ds / kf)))
        let right = max(0, Int(ceil((bounds.width - x - w) * ds / kf)))
        let top = max(0, Int(ceil(y * ds / kf)))
        let bottom = max(0, Int(ceil((bounds.height - y - hh) * ds / kf)))
        let cols = left + Layout.width + right, rows = top + h + bottom
        engine.configureStars(cols: cols, rows: rows)
        starLayer.frame = CGRect(x: x - CGFloat(left) * pointsPerPixel, y: y - CGFloat(top) * pointsPerPixel,
                                 width: CGFloat(cols) * pointsPerPixel, height: CGFloat(rows) * pointsPerPixel)
        starLayer.contents = engine.renderStarsImage()
        screenLayer.contents = engine.renderImage()
        CATransaction.commit()
    }

    private func makeScanlines(rows: Int, k: Int) -> CGImage? {
        guard k >= 3 else { return nil }
        let height = rows * k
        var data = [UInt8](repeating: 0, count: height * 4)
        for r in 0..<height where r % k == k - 1 { data[r * 4 + 3] = 110 }
        guard let provider = CGDataProvider(data: Data(data) as CFData) else { return nil }
        return CGImage(width: 1, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }

    // Dokunmatik: alt paneldeki SOL / SAĞ / ATEŞ düğmeleri ve üstteki duraklatma düğmesi.
    private var activeTouches = Set<UITouch>()

    private func logical(_ t: UITouch) -> CGPoint {
        let p = t.location(in: self)
        return CGPoint(x: (p.x - screenLayer.frame.minX) / pointsPerPixel,
                       y: (p.y - screenLayer.frame.minY) / pointsPerPixel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.formUnion(touches)
        engine.touchesBegan(touches.map(logical))
        engine.setActiveTouches(activeTouches.map(logical))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        engine.setActiveTouches(activeTouches.map(logical))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.subtract(touches); engine.setActiveTouches(activeTouches.map(logical))
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.subtract(touches); engine.setActiveTouches(activeTouches.map(logical))
    }
}

extension GameScreenView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        engine.importSave(from: url)
    }
}

struct GameScreen: UIViewRepresentable {
    func makeUIView(context: Context) -> GameScreenView { GameScreenView(frame: .zero) }
    func updateUIView(_ uiView: GameScreenView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GameScreen()
                .ignoresSafeArea()   // yıldızlar çentik / ana ekran çubuğu dahil tüm ekranı kaplasın
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }
}

#Preview { ContentView() }

struct MYKCyberpunk_GalagaApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

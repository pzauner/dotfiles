# eGPU Setup Guide: AMD RX 6800 & Razer Core X unter Fedora 43 (ThinkPad T14 Gen 2i)

Diese Dokumentation beschreibt die erfolgreiche Einrichtung einer AMD Radeon RX 6800 eGPU in einem Razer Core X Gehäuse an einem Lenovo ThinkPad T14 Gen 2i unter Fedora 43 mit KDE Plasma.

## 1. Hardware-Voraussetzungen & Fehlerbehebung
*   **Thunderbolt-Kabel:** Ein passives 1,8m USB-C Kabel reichte für den DP-Alt-Mode, scheiterte aber am PCIe-Tunneling für die eGPU (Symptom: Pulsierender Gehäuselüfter, kein Eintrag in `lsusb`/`boltctl`).
*   **Lösung:** Einsatz eines hochwertigen **0,5m - 0,8m Thunderbolt 4 Kabels** (40 Gbps). Erst damit wurde ein stabiler Handshake erreicht.
*   **Stromversorgung:** Die RX 6800 benötigt zwingend beide 8-Pin PCIe-Stromstecker vom Razer Core X Netzteil.

## 2. BIOS-Einstellungen (ThinkPad-spezifisch)
Damit die eGPU auf PCIe-Ebene erkannt wird, müssen folgende Einstellungen im BIOS (F1 beim Booten) gesetzt sein:
*   **Security -> Virtualization -> Kernel DMA Protection:** `OFF` (Zwingend erforderlich für eGPU-Erkennung).
*   **Config -> Thunderbolt 3/4:** Security Level auf `No Security` (erleichtert die Autorisierung unter Linux).
*   **Thunderbolt BIOS Assist Mode:** `Disabled`.

## 3. Kernel-Parameter (GRUB)
Aufgrund begrenzter PCI-Ressourcen (Bus-Nummern und Adressraum) am T14 Gen 2i muss der Kernel angewiesen werden, Ressourcen neu zu verteilen.

Die Datei `/etc/default/grub` wurde wie folgt angepasst:
```text
GRUB_CMDLINE_LINUX="pci=realloc,assign-busses,hp_accel,pci_realloc_bars,nocrs intel_iommu=off amdgpu.smart_shift_v1=0 amdgpu.aspm=0 rd.luks.uuid=... quiet"
```

### Erklärung der Parameter:
*   `pci=realloc,assign-busses,pci_realloc_bars`: Zwingt den Kernel, PCI-Busse und Ressourcen neu zu vergeben.
*   `nocrs`: Ignoriert BIOS-Ressourcen-Beschränkungen (Host Bridge Current Resource Settings).
*   `intel_iommu=off`: Deaktiviert die IOMMU-Gängelung, um DMA-Fehler beim Hot-Plugging zu vermeiden.
*   `amdgpu.aspm=0`: Deaktiviert Stromsparmechanismen des Treibers für stabilere Latenzen.

**Update der Konfiguration:**
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## 4. Desktop-Umgebung & Performance-Optimierung (X11 vs. Wayland)

### Das Bandbreiten-Problem (Reverse PRIME)
Unter **Wayland** bleibt die interne Intel-GPU oft der "Master-Renderer". Das fertige Bild muss von der eGPU zur CPU und zurück zum Monitor kopiert werden. Bei hohen Bildwiederholraten (z.B. **175Hz WQHD**) verstopft dieser Rückkanal den Thunderbolt-Bus massiv.
*   **Symptom:** FPS-Einbruch von ~140 FPS (60Hz) auf ~100 FPS (175Hz) in Benchmarks.

### Die Lösung: X11 Session
Unter **X11** kann die RX 6800 als primäre GPU ohne Kopier-Overhead agieren.
*   **Ergebnis:** Steigerung auf **215 FPS** (GravityMark Score: 35.905).
*   **Vorgehensweise:** Installation von `plasma-workspace-x11` und Auswahl von "Plasma (X11)" im Login-Screen.
*   **Optimierung:** Erstellung einer Xorg-Konfiguration unter `/etc/X11/xorg.conf.d/99-egpu.conf` zur Aktivierung von VRR:
    ```text
    Section "Device"
        Identifier  "AMD-eGPU"
        Driver      "amdgpu"
        BusID       "PCI:7:0:0"
        Option      "PrimaryGPU" "yes"
        Option      "VariableRefresh" "true"
    EndSection
    ```

## 5. Hot-Plug & Dock-Stabilität
Um das System als Dock zu nutzen und "Bricks" beim Abziehen zu vermeiden:

### Udev-Regel (`/etc/udev/rules.d/99-egpu-hotplug.rules`)
Sorgt für sauberes Aufräumen des PCI-Bus:
```text
ACTION=="remove", SUBSYSTEM=="thunderbolt", RUN+="/usr/bin/sh -c 'echo 1 > /sys/bus/pci/rescan'"
```

### TLP-Konfiguration (`/etc/tlp.conf`)
Verhindert, dass die GPU im Idle-Modus in einen instabilen Schlafzustand geht:
```text
RUNTIME_PM_DENYLIST="07:00.0"
```

## 6. Benchmarks & Limits
*   **GravityMark (Vulkan):** 215.0 FPS (Score 35.905) @ 1600x900.
*   **Limitierung:** Da das T14 Gen 2i kein **Resizable BAR** unterstützt, bleibt die Karte auf einem 256MB BAR-Fenster begrenzt. Dies verhindert das Erreichen der absoluten Leaderboard-Spitzenwerte (~235+ FPS), ist aber für Thunderbolt-Verhältnisse ein exzellenter Wert.

---
**Status:** Erfolgreich eingerichtet und optimiert am 31. Jan 2026.

{ flake, system, pkgs, ...}:
flake.inputs.gastown.packages.${system}.gt.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    sed -i '/"syscall"/d' internal/cmd/daemon.go
    sed -i 's/process.Signal(syscall.SIGUSR2)/process.Signal(reloadSignal())/' internal/cmd/daemon.go

    cat > internal/cmd/reload_signal_unix.go <<'EOF'
//go:build !windows

package cmd

import (
	"os"
	"syscall"
)

func reloadSignal() os.Signal {
	return syscall.SIGUSR2
}
EOF

      cat > internal/cmd/reload_signal_windows.go <<'EOF'
//go:build windows

package cmd

import "os"

func reloadSignal() os.Signal {
	return os.Interrupt
}
EOF
    '';

  proxyVendor = true;
  vendorHash = "sha256-2JKhctfOQw4EO7aWDk5eEto94EGzOAcc5qF5S1EKnXY=";
})

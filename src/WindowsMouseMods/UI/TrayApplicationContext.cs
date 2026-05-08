using WindowsMouseMods.Core;

namespace WindowsMouseMods.UI;

internal sealed class TrayApplicationContext : ApplicationContext
{
    private readonly NotifyIcon _trayIcon;
    private readonly RightClickLockController _controller;
    private readonly AppSettings _settings;
    private MainForm? _mainForm;
    private DebugForm? _debugForm;
    private readonly ToolStripMenuItem _enabledItem;
    private readonly ToolStripMenuItem _debugItem;

    public TrayApplicationContext()
    {
        _settings = AppSettings.Load();
        _controller = new RightClickLockController(_settings);
        _controller.LockStateChanged += (_, _) => UpdateTrayIcon();

        _enabledItem = new ToolStripMenuItem("Enabled", null, OnToggleEnabled) { Checked = _settings.Enabled, CheckOnClick = true };
        _debugItem = new ToolStripMenuItem("Show debug window", null, (_, _) => ToggleDebugWindow()) { CheckOnClick = false };

        var menu = new ContextMenuStrip();
        menu.Items.Add(_enabledItem);
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("Settings...", null, (_, _) => ShowMainForm());
        menu.Items.Add(_debugItem);
        menu.Items.Add(new ToolStripSeparator());
        menu.Items.Add("Exit", null, (_, _) => ExitApplication());

        _trayIcon = new NotifyIcon
        {
            Icon = SystemIcons.Application,
            Visible = true,
            Text = "Windows Mouse Mods",
            ContextMenuStrip = menu,
        };
        _trayIcon.DoubleClick += (_, _) => ShowMainForm();

        try
        {
            _controller.Start();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to install hooks:\n{ex.Message}", "Windows Mouse Mods",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        UpdateTrayIcon();

        if (_settings.ShowDebugOnStartup)
            ShowDebugWindow();

        if (!_settings.StartMinimized)
            ShowMainForm();
    }

    private void OnToggleEnabled(object? sender, EventArgs e)
    {
        _settings.Enabled = _enabledItem.Checked;
        _controller.ApplySettings(_settings);
        _settings.Save();
        UpdateTrayIcon();
    }

    private void UpdateTrayIcon()
    {
        var status = !_settings.Enabled ? "disabled"
            : _controller.Locked ? "locked"
            : "ready";
        _trayIcon.Text = $"Windows Mouse Mods — {status}";
    }

    public void ShowMainForm()
    {
        if (_mainForm == null || _mainForm.IsDisposed)
        {
            _mainForm = new MainForm(_settings, _controller, OnSettingsSaved, ExitApplication);
            _mainForm.FormClosed += (_, _) => _mainForm = null;
        }
        _mainForm.Show();
        _mainForm.WindowState = FormWindowState.Normal;
        _mainForm.BringToFront();
        _mainForm.Activate();
    }

    public void ShowDebugWindow()
    {
        if (_debugForm == null || _debugForm.IsDisposed)
        {
            _debugForm = new DebugForm(_controller);
            _debugForm.FormClosed += (_, _) =>
            {
                _debugForm = null;
                _debugItem.Checked = false;
                if (_settings.ShowDebugOnStartup)
                {
                    _settings.ShowDebugOnStartup = false;
                    _settings.Save();
                }
            };
        }
        _debugForm.Show();
        _debugForm.WindowState = FormWindowState.Normal;
        _debugForm.BringToFront();
        _debugForm.Activate();
        _debugItem.Checked = true;

        if (!_settings.ShowDebugOnStartup)
        {
            _settings.ShowDebugOnStartup = true;
            _settings.Save();
        }
    }

    private void ToggleDebugWindow()
    {
        if (_debugForm != null && !_debugForm.IsDisposed)
        {
            _debugForm.Close();
        }
        else
        {
            ShowDebugWindow();
        }
    }

    private void OnSettingsSaved()
    {
        _enabledItem.Checked = _settings.Enabled;
        _controller.ApplySettings(_settings);
        UpdateTrayIcon();
    }

    public void ExitApplication()
    {
        _controller.Dispose();
        _trayIcon.Visible = false;
        _trayIcon.Dispose();
        ExitThread();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _controller.Dispose();
            _trayIcon.Dispose();
        }
        base.Dispose(disposing);
    }
}

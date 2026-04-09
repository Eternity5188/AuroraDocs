import { app, BrowserWindow, shell, Menu, Tray, ipcMain, nativeImage } from 'electron'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const isDev = process.env.NODE_ENV === 'development'
let tray = null
let mainWindow = null

if (process.platform === 'win32') {
  app.setAppUserModelId('com.auroradocs.app')
}

function createMenu() {
  const template = [
    {
      label: 'File',
      submenu: [
        { role: 'quit', label: '退出' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo', label: '撤销' },
        { role: 'redo', label: '重做' },
        { type: 'separator' },
        { role: 'cut', label: '剪切' },
        { role: 'copy', label: '复制' },
        { role: 'paste', label: '粘贴' },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload', label: '刷新' },
        { role: 'toggledevtools', label: '切换开发者工具' },
      ],
    },
    {
      label: 'Help',
      submenu: [
        {
          label: '关于 AuroraDocs',
          click: () => {
            shell.openExternal('https://auroradocs.example.com')
          },
        },
      ],
    },
  ]
  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
}

function createTray() {
  const iconDataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAFklEQVR42mNgGAXUBwYCBn4GBgYHgAANEgOB4vW0YwAAAAASUVORK5CYII='
  const icon = nativeImage.createFromDataURL(iconDataUrl)
  tray = new Tray(icon)
  const contextMenu = Menu.buildFromTemplate([
    {
      label: '显示 AuroraDocs',
      click: () => {
        if (mainWindow) {
          mainWindow.show()
          mainWindow.focus()
        }
      },
    },
    {
      label: '退出',
      click: () => {
        app.isQuiting = true
        app.quit()
      },
    },
  ])
  tray.setToolTip('AuroraDocs')
  tray.setContextMenu(contextMenu)
  tray.on('double-click', () => {
    if (mainWindow) {
      mainWindow.show()
      mainWindow.focus()
    }
  })
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1200,
    height: 820,
    minWidth: 980,
    minHeight: 680,
    show: false,
    title: 'AuroraDocs',
    autoHideMenuBar: false,
    frame: false,
    titleBarStyle: 'hidden',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  })

  win.once('ready-to-show', () => win.show())

  win.on('minimize', (event) => {
    if (minimizeToTray) {
      event.preventDefault()
      win.hide()
    }
  })

  win.on('close', (event) => {
    if (!app.isQuiting) {
      event.preventDefault()
      win.hide()
    }
  })

  if (isDev) {
    win.loadURL('http://localhost:5173')
  } else {
    win.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  win.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })

  return win
}

let minimizeToTray = true // 默认值

ipcMain.handle('get-setting', (event, key) => {
  if (key === 'minimizeToTray') {
    return minimizeToTray
  }
  return null
})

ipcMain.handle('set-setting', (event, key, value) => {
  if (key === 'minimizeToTray') {
    minimizeToTray = value
  }
})

app.whenReady().then(() => {
  createMenu()
  mainWindow = createWindow()
  createTray()
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    mainWindow = createWindow()
  }
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

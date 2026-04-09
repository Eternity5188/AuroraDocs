import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('electron', {
  platform: process.platform,
  control: {
    minimize: () => ipcRenderer.invoke('window-control', 'minimize'),
    maximize: () => ipcRenderer.invoke('window-control', 'maximize'),
    close: () => ipcRenderer.invoke('window-control', 'close'),
    isMaximized: () => ipcRenderer.invoke('window-control', 'isMaximized'),
  },
  settings: {
    getMinimizeToTray: () => ipcRenderer.invoke('get-setting', 'minimizeToTray'),
    setMinimizeToTray: (value) => ipcRenderer.invoke('set-setting', 'minimizeToTray', value),
  },
})

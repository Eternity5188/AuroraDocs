import axios from 'axios'

const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api'

export const apiClient = axios.create({
  baseURL,
  timeout: 20000,
})

export async function uploadSample(file) {
  const formData = new FormData()
  formData.append('file', file)
  const response = await apiClient.post('/train/samples', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })
  return response.data
}

export async function createTrainingTask(payload) {
  const response = await apiClient.post('/train/tasks', payload)
  return response.data
}

export async function getTaskStatus(taskId) {
  const response = await apiClient.get(`/train/tasks/${taskId}`)
  return response.data
}

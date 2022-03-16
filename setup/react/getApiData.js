const API_URL = import.meta.env.VITE_API_URL

const getApiData = async (endpoint) => {
  const response = await fetch(API_URL + endpoint)
  const data = await response.json()
  return data
}

export default getApiData

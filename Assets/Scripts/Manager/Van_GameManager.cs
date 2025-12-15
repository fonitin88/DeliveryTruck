using UnityEngine;
using UnityEngine.SceneManagement;

public class Van_GameManager : MonoBehaviour
{
    public static Van_GameManager Instance { get; private set; }
    public GameObject Player { get; private set; }

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;

        Player = GameObject.FindGameObjectWithTag("Player");
    }

    public void RestartLevelButton()
    {
        Time.timeScale = 1f;
        int currentScene = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentScene);
    }
    public void QuitButton()
    {
        Application.Quit();
    }

    public void PlayButton()
    {
        Time.timeScale = 1f;
        SceneLoader.Load("Van_Main");

    }

    public void BackToMainButton()
    {
        SceneLoader.Load("Menu");
    }

}

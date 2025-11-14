using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SSGameManager : MonoBehaviour
{
    [SerializeField] TMP_Text EnemiesLeftText;
    [SerializeField] GameObject YouWinText;//因為要使用active功能所以用gameobject

    int enemiesLeft = 0;

    const string ENEMIES_LEFT_STRING = "Enemies Left: ";//要顯示的文字

    public void AdjustEnemiesLeft(int amount)
    {
        enemiesLeft += amount;//計算目前多少隻敵人

        if (enemiesLeft <= 0)
        {
            YouWinText.SetActive(true);
        }
        else
        {
            EnemiesLeftText.text = ENEMIES_LEFT_STRING + enemiesLeft.ToString();
        }
    }

    public void RestartLevelButton()
    {
        int currentScene = SceneManager.GetActiveScene().buildIndex;
        SceneManager.LoadScene(currentScene);
    }
    public void QuitButton()
    {
        Application.Quit();
    }
}

using System.Collections;
using TMPro;
using UnityEngine;

public class TImeManager : MonoBehaviour
{
    public static TImeManager Instance { get; private set; }
    [SerializeField] TMP_Text timeText;
    [SerializeField] float startTime = 5f;
    [SerializeField] GameObject TimesupUI;

    float timeLeft;
    bool gameOver = false;

    public bool GameOver => gameOver;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
    }

    void Start()
    {
        timeLeft = startTime;
    }
    void Update()
    {
        DecreaseTime();
    }

    public void IncreaseTime(float amount)
    {
        timeLeft += amount;
    }

    void DecreaseTime()
    {
        if (gameOver) return;
        timeLeft -= Time.deltaTime;
        int seconds = Mathf.CeilToInt(timeLeft);
        //一個是除與60=1分鐘 後面是取餘數
        timeText.text = $"{seconds / 60:00}:{seconds % 60:00}";
        if (timeLeft <= 0f)
        {
            PlayerGameOver();
        }
    }

    void PlayerGameOver()
    {
        gameOver = true;
        Time.timeScale = 0f;
        StartCoroutine(UIdelay());
    }
    IEnumerator UIdelay()
    {
        yield return new WaitForSecondsRealtime(1f);
        TimesupUI.SetActive(true);

    }


}

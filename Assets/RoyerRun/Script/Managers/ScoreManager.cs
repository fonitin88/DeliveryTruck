using TMPro;
using UnityEngine;

public class ScoreManager : MonoBehaviour
{
    [SerializeField] GameManager gameManager;
    [SerializeField] TMP_Text scoreboardText;

    int score = 0;

    public void IncreaseScore(int amount)
    {
        if (gameManager.GameOver) return;//Gameover 之後 就算吃掉coin也不要增加分數

        score += amount;
        scoreboardText.text = score.ToString();//是把整數轉成字串
    }
}

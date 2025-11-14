using TMPro;
using UnityEngine;

public class BonusManager : MonoBehaviour
{
    [SerializeField] TMP_Text BonusText;
    [SerializeField] TMP_Text GiftText;

    int score = 0;

    public void IncreaseScore(int amount)
    {
        score += amount;
        BonusText.text = score.ToString();
        GiftText.text = "+" + score.ToString();
    }
}

using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class HealthManager : MonoBehaviour
{
    [SerializeField] TMP_Text HealthText;
    [SerializeField] Van_AllHealth playerHealth; // 指定玩家那個
    public Slider slider;

    void Start()
    {
        playerHealth.OnHealthChanged += UpdateUI;
        slider.maxValue = playerHealth.GetCurrentHealth();
        UpdateUI(playerHealth.GetCurrentHealth());

    }

    void UpdateUI(int current)
    {
        HealthText.text = current.ToString("D2");
        slider.value = current;
    }
}

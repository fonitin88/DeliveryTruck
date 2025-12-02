using UnityEngine;

public class PlayerDeathHandler : MonoBehaviour
{
    [SerializeField] GameObject GameOverUI;
    [SerializeField] GameObject player;
    void Start()
    {
        Van_AllHealth Playerhealth = player.GetComponent<Van_AllHealth>();
        Playerhealth.OnDeath += HandleGameOver;
    }

    void HandleGameOver()
    {
        Debug.Log("GG");
        TImeManager.Instance.HideTimer();
        Time.timeScale = 0f;
        GameOverUI.SetActive(true);
    }
}

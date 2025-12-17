using System.Collections;
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
        Time.timeScale = 0f;
        StartCoroutine(UIdelay());
    }
    IEnumerator UIdelay()
    {
        yield return new WaitForSecondsRealtime(1f);
        GameOverUI.SetActive(true);
    }
}

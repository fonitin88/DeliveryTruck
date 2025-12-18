using System;
using System.Collections;
using UnityEngine;


public class Van_AllHealth : MonoBehaviour, IDamageable
{
    [SerializeField] int startingHealth = 3;
    [SerializeField] GameObject explosionVFX;
    [SerializeField] GameObject modelHolder; // 只控制外觀

    int currentHealth;
    bool isDead;
    public event Action<int> OnHealthChanged;
    public event Action OnDeath;
    public int GetCurrentHealth()
    {
        return currentHealth;// 外部只能讀，不能改
    }


    void Awake()
    {
        currentHealth = startingHealth;
        OnHealthChanged?.Invoke(currentHealth); // 目前血量是多少,通知 UI
    }

    public void TakeDamage(int amount)
    {
        if (isDead) return;
        if (currentHealth > 0)
        {
            currentHealth -= amount;
            OnHealthChanged?.Invoke(currentHealth);//當受到傷害時，血量改變了,通知 UI
        }

        if (currentHealth <= 0)
        {
            isDead = true;
            StartCoroutine(HandleDeath());
        }
    }

    public void IncreaseHealth(int amount)
    {
        currentHealth += amount;
        currentHealth = Mathf.Min(currentHealth, startingHealth); // 不超過上限
        OnHealthChanged?.Invoke(currentHealth); //當補血時，血量改變了,通知 UI
    }

    IEnumerator HandleDeath()
    {
        Instantiate(explosionVFX, transform.position, Quaternion.identity);
        modelHolder.SetActive(false);
        yield return new WaitForSeconds(1f);
        OnDeath?.Invoke();//死了後通知外部 
        Debug.Log("OnDeath invoked");

    }

}

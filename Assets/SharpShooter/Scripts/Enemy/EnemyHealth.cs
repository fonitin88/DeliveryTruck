using Unity.VisualScripting;
using UnityEngine;

public class EnemyHealth : MonoBehaviour
{
    [SerializeField] GameObject VFX_Explosion;
    [SerializeField] int startingHealth = 3;

    int currentHealth;

    SSGameManager sSGameManager;

    void Awake()
    {
        currentHealth = startingHealth;
    }

    void Start()
    {
        //為了顯示有多少個敵人而已
        sSGameManager = FindFirstObjectByType<SSGameManager>();
        sSGameManager.AdjustEnemiesLeft(1);//每生成一個敵人，就把敵人標1
    }

    public void TakeDamage(int amount)
    {
        currentHealth -= amount;
        if (currentHealth <= 0)
        {
            sSGameManager.AdjustEnemiesLeft(-1);
            SelfDestruct();
        }
    }

    public void SelfDestruct()
    {
        Instantiate(VFX_Explosion, transform.position, Quaternion.identity);
        Destroy(this.gameObject);
    }
}

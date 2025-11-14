using UnityEngine;

public class Enemy : MonoBehaviour
{
    [SerializeField] GameObject destroyedVFX;
    [SerializeField] int hitPoints = 3;
    [SerializeField] int scoreValue = 10;

    Scoreboard scoreboard; //叫出Scoreboard
    void Start()
    {
        scoreboard = FindFirstObjectByType<Scoreboard>();//在場景中找第一個掛有 Scoreboard 腳本的物件
    }

    void OnParticleCollision(GameObject other)
    {
        ProcessHit();
    }

    void ProcessHit()
    {
        hitPoints--;
        if (hitPoints <= 0)
        {
            scoreboard.IncreaseScore(scoreValue);//呼叫 Scoreboard 的方法來加分
            Instantiate(destroyedVFX, transform.position, Quaternion.identity);//分身(指定要誰是分身>特效,位置,沒有旋轉)
            Destroy(this.gameObject);
        }
    }
}

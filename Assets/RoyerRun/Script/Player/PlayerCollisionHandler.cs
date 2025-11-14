using UnityEngine;

public class PlayerCollisionHandler : MonoBehaviour
//碰到collision會有什麼動作
{
    [SerializeField] Animator animator;
    [SerializeField] float collisionCooldown = 1f;//cooldownTimer,觸發動畫之間，至少要間隔 1 秒
    [SerializeField] float adjustChangeMoveSpeedAmount = -2f;

    const string hitString = "Hit";
    float cooldownTimer = 0f;//cooldownTimer

    LevelGenerator levelGenerator;

    void Start()
    {
        levelGenerator = FindFirstObjectByType<LevelGenerator>();

    }

    void Update()
    {
        cooldownTimer += Time.deltaTime;
        //Debug.Log($"cooldownTimer = {cooldownTimer:F3} 秒"); ★ 這行會把目前累積秒數印到 Console
    }

    void OnCollisionEnter(Collision collision)
    {
        if (cooldownTimer < collisionCooldown) return;//cooldownTimer，<1f不執行後面的動畫

        levelGenerator.ChangeChunkMoveSpeed(adjustChangeMoveSpeedAmount);//撞到物件就會降低速度
        animator.SetTrigger(hitString);
        cooldownTimer = 0f;//cooldownTimer
    }
}

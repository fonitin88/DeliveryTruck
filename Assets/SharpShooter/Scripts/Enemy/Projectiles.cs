using UnityEngine;

public class Projectiles : MonoBehaviour
{
    [SerializeField] float speed = 10f;
    [SerializeField] GameObject ProjectilesVFX;

    Rigidbody rb;
    int damage;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Start()
    {
        rb.linearVelocity = transform.forward * speed;//移動速度
    }

    public void Init(int damage)//自訂的初始化方法
    {
        this.damage = damage;//左邊:自己的欄位，右邊是傳進來的參數
    }

    void OnTriggerEnter(Collider other)
    {
        PlayerHealth playerHealth = other.GetComponent<PlayerHealth>();
        playerHealth?.TakeDamage(damage);
        Instantiate(ProjectilesVFX, transform.position, Quaternion.identity);

        Destroy(this.gameObject);
    }

}

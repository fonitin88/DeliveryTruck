using UnityEngine;

public abstract class BasePickup : MonoBehaviour
{
    [SerializeField] float rotationSpeed = 100f;

    const string PLAYER_STRING = "Player";//判斷是不是玩家

    void Update()
    {
        transform.Rotate(0f, rotationSpeed * Time.deltaTime, 0f);
    }

    void OnTriggerEnter(Collider other)//撿東西用一下
    {
        if (other.CompareTag(PLAYER_STRING))//先判斷是不是玩家
        {
            //只用一次variable，都需要所以寫在pickup
            ActiveWeapon activeWeapon = other.GetComponentInChildren<ActiveWeapon>();
            OnPickup(activeWeapon);
            Destroy(this.gameObject);
        }
    }
    protected abstract void OnPickup(ActiveWeapon activeWeapon);
}

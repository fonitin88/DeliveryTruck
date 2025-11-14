using UnityEngine;

public abstract class Pickup : MonoBehaviour
{
    const string playerString = "Player";//const意思是不能改string
    [SerializeField] float rotationSpeed = 100f;
    void Update()
    {
        transform.Rotate(0f, rotationSpeed * Time.deltaTime, 0f);
    }

    void OnTriggerEnter(Collider other)
    {

        if (other.CompareTag(playerString))//也可以other.gameObject.tag == playerString
        {
            OnPickup();
            Destroy(gameObject);
        }
    }
    protected abstract void OnPickup();
}

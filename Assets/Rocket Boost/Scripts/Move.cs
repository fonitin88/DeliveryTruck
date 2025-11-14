using UnityEngine;


public class Move : MonoBehaviour
{
    [SerializeField] float moveSpeed = 10f;

    void Update()
    {
        MovePlayer();
    }

    void MovePlayer()
    {
        float XValue = Input.GetAxis("Horizontal") * Time.deltaTime * moveSpeed;
        float YValue = 0;
        float ZValue = Input.GetAxis("Vertical") * Time.deltaTime * moveSpeed;
        transform.Translate(XValue, YValue, ZValue);
    }
}

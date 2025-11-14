using UnityEngine;
using UnityEngine.InputSystem;


public class PlayerAttack : MonoBehaviour
{
    [SerializeField] GameObject FX_Lightray;
    [SerializeField] Transform FXShootPos;

    public void OnShoot(InputValue input)
    {
        if (input.isPressed)
        {
            GameObject fx = Instantiate(FX_Lightray, FXShootPos.position, transform.rotation);
            fx.transform.SetParent(FXShootPos);

            Destroy(fx, 0.5f);
        }
    }


}

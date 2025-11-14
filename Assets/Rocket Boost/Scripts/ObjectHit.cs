using UnityEngine;

public class ObjectHit : MonoBehaviour

{
    private void OnCollisionEnter(Collision other)
    {
        //如果是hit by player , turn to black
        if (other.gameObject.tag == "Player")//物件要設定tag
        {
            GetComponent<MeshRenderer>().material.color = Color.black;
            gameObject.tag = "Hit"; //當player hit this object change the tag to Hit
        }

    }
}

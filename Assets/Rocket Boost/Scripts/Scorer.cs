using UnityEngine;

public class Scorer : MonoBehaviour
{
    int Hits = 0;
    private void OnCollisionEnter(Collision other)
    {
        //only hit once time get scorer
        if (other.gameObject.tag != "Hit")// 在ObjectHit這個cs 有註明Hit這個tag
        {
            Hits++;
            Debug.Log("You're bumped into a thing this many times: " + Hits);
        }

    }
}

import { useState } from "react";
import { getItemUrl } from "../../helpers";
import { imagepath } from "../../store/imagepath";
import useNuiEvent from "../../hooks/useNuiEvent";
import { fetchNui } from "../../utils/fetchNui";

const ammoListByGroup : Record<string, Record<string,string>> = {
    arrow: {
        normal: 'arrow_type_normal',
        confusion: 'arrow_type_confusion',
        disoriented: 'arrow_type_disoriented',
        drained: 'arrow_type_drained',
        explosive: 'arrow_type_explosive',
        fire: 'arrow_type_fire',
        improved: 'arrow_type_improved',
        poison: 'arrow_type_poison',
        small_game: 'arrow_type_small_game',
        trail: 'arrow_type_trail',
        wounded: 'arrow_type_wounded',
    },
    bullet: {
        normal: 'bullet_normal',
        express: 'bullet_express',
        express_explosive: 'bullet_express_explosive',
        high_velocity: 'bullet_high_velocity',
        incendiary: 'bullet_incendiary',
        split_point: 'bullet_split_point',
        varmint: 'bullet_varmint',
    },
    dynamite: {
        normal: 'dynamite_normal',
        volatile: 'dynamite_volatile',
    },
    shotgun: {
        normal: 'shotgun_normal',
        explosive: 'shotgun_explosive',
        slug: 'shotgun_slug',
    },
    tomahawk: {
        normal: 'tomahawk_normal',
        ancient: 'tomahawk_ancient',
        homing: 'tomahawk_homing',
        improved: 'tomahawk_improved',
    }
}

export const ContainerAmmo = ({ display }: {display: boolean}) => {
    const [ammoGroup, setAmmoGroup ] = useState('arrow');
    const ammoTypes = ammoListByGroup[ammoGroup];

    const [currentAmmo, setCurrentAmmo] = useState('arrow_type_improved');
    const [ammoName, setAmmoName] = useState('arrow_type_improved');

    const handleSelectAmmo = (ammo: string) => {
        setCurrentAmmo(ammo)
        fetchNui('updateCurrentAmmo', ammo);
    }

    const handleCurrentAmmo = ( data : any ) => {
        setCurrentAmmo( data.hash )
        setAmmoName( data.name )
    }

    useNuiEvent('setCurrentAmmo', handleCurrentAmmo);
    useNuiEvent('setAmmoGroup', setAmmoGroup);

    return (
        <div
            className="ammoTypeContainer"

            style={{
                opacity: display ? 1.0 : 0
            }}
        >
            <div>
                {Object.keys(ammoTypes).map((keyName, i) => (
                    <img
                        onClick={() => handleSelectAmmo(ammoTypes[keyName] as string)}
                        src={`${imagepath}/ammo_types/${ammoTypes[keyName]}.png`}
                        className={`ammoImage ${currentAmmo == ammoTypes[keyName] ? 'currentAmmo' : ''}`}
                        key={i}
                    />
                ))}
            </div>
            <span> {ammoName} </span>
        </div>
    )
}
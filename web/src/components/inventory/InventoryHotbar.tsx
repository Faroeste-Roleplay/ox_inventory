import React, { useState } from 'react';
import { getItemUrl, isSlotWithItem } from '../../helpers';
import useNuiEvent from '../../hooks/useNuiEvent';
import { Items } from '../../store/items';
import WeightBar from '../utils/WeightBar';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { SlotWithItem } from '../../typings';
import SlideUp from '../utils/transitions/SlideUp';
import { isEnvBrowser } from '../../utils/misc';
import { ContainerAmmo } from './InventoryAmmo';

const InventoryHotbar: React.FC = () => {
  const [hotbarVisible, setHotbarVisible] = useState(isEnvBrowser());
  const items = useAppSelector(selectLeftInventory).items.slice(0, 5);

  //stupid fix for timeout
  const [handle, setHandle] = useState<NodeJS.Timeout>();
  useNuiEvent('toggleHotbar', () => {
    if (hotbarVisible) {
      setHotbarVisible(false);
    } else {
      if (handle) clearTimeout(handle);
      setHotbarVisible(true);
      setHandle(setTimeout(() => setHotbarVisible(false), 3000));
    }
  });

  return (
    <>
      <ContainerAmmo display={hotbarVisible} />
      <SlideUp in={hotbarVisible}>
        <div className="hotbar-container">
          {items.map((item) => (
            <div
              className="hotbar-item-slot"

              key={`hotbar-${item.slot}`}
            >
              <div className="inventory-slot-number">{item.slot}</div>
              {isSlotWithItem(item) && (
                <div className="item-slot-wrapper"
                  style={{
                    backgroundImage: `url(${item?.name ? getItemUrl(item as SlotWithItem) : 'none'}`,
                    backgroundRepeat: "no-repeat",
                    backgroundPosition: "center"
                  }}
                >
                  <div className="hotbar-slot-header-wrapper">
                    <div className="item-slot-info-wrapper">
                      <p>
                        {item.weight > 0
                          ? item.weight >= 1000
                            ? `${(item.weight / 1000).toLocaleString('en-us', {
                              minimumFractionDigits: 2,
                            })}kg `
                            : `${item.weight.toLocaleString('en-us', {
                              minimumFractionDigits: 0,
                            })}g `
                          : ''}
                      </p>
                      <p>{item.count ? item.count.toLocaleString('en-us') + `x` : ''}</p>
                    </div>
                  </div>
                  <div>

                    <div className="item-slot-info-wrapper">
                      <p>
                        {item.weight > 0
                          ? item.weight >= 1000
                            ? `${(item.weight / 1000).toLocaleString('en-us', {
                              minimumFractionDigits: 2,
                            })}kg `
                            : `${item.weight.toLocaleString('en-us', {
                              minimumFractionDigits: 0,
                            })}g `
                          : ''}
                      </p>
                      {item?.name?.toLocaleLowerCase().search("weapon") != -1 && item?.name?.toLocaleLowerCase().search("weapon") != undefined
                        ? <span> {item.metadata?.ammo}/{item.metadata?.ammoMaxClip ?? item.metadata?.ammo}</span>
                        : <span>{item.count > 1 ? item.name == "money" ? `${(item.count / 100).toFixed(2)}` : item.count.toLocaleString('en-us') : ''}</span>
                      }
                    </div>

                    {item?.name?.toLocaleLowerCase().search("weapon") != -1 && item?.name?.toLocaleLowerCase().search("weapon") != undefined
                      ? item?.degradation !== undefined && <WeightBar percent={item.degradation} durability />
                      : item?.durability !== undefined && <WeightBar percent={item.durability} durability />
                    }

                    <div className="inventory-slot-label-box">
                      <div className="inventory-slot-label-text">
                        {item.metadata?.label ? item.metadata.label : Items[item.name]?.label || item.name}
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </SlideUp>
    </>

  );
};

export default InventoryHotbar;

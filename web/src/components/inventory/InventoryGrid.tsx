import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Inventory } from '../../typings';
import WeightBar from '../utils/WeightBar';
import InventorySlot from './InventorySlot';
import { getTotalWeight } from '../../helpers';
import { useAppSelector } from '../../store';
import { useIntersection } from '../../hooks/useIntersection';
import InventoryControl from './InventoryControl';

const PAGE_SIZE = 30;

const InventoryGrid: React.FC<{ inventory: Inventory, isRight?: boolean }> = ({ inventory, isRight = false }) => {
  const weight = useMemo(
    () => (inventory.maxWeight !== undefined ? Math.floor(getTotalWeight(inventory.items) * 1000) / 1000 : 0),
    [inventory.maxWeight, inventory.items]
  );
  const [page, setPage] = useState(0);
  const [inventoryVisible, setInventoryVisible] = useState<boolean>(false);
  const containerRef = useRef(null);
  const { ref, entry } = useIntersection({ threshold: 0.5 });
  const isBusy = useAppSelector((state) => state.inventory.isBusy);

  useEffect(() => {        
    checkInventoryNeedOpen()
  }, [inventory])

  const checkInventoryNeedOpen = function()
    {
        if (inventory.type == "player")
        {
          setInventoryVisible(true)
        }
        else
        {
          if ( !inventory.id )
          {
              setInventoryVisible(false)
          }
          else
          {
              setInventoryVisible(true)
          }
        }
    }

  useEffect(() => {
    if (entry && entry.isIntersecting) {
      setPage((prev) => ++prev);
    }
  }, [entry]);
  return (
    <div className={`rootInventory`}>
    
      {inventory.type == "player"?             
          <InventoryControl />
      : ''}

      <div className={`inventory-grid-wrapper inventory_background ${inventoryVisible ? 'active' : ''}`}  style={{ pointerEvents: isBusy ? 'none' : 'auto' }}>
        <div>
          <div className="inventory-grid-header-wrapper">
            <p>{inventory.label}</p>
          </div>
        </div>
        <div className="inventory-grid-container" style={{
          
        }}ref={containerRef}>
          <>
            {inventory.items.slice(0, (page + 1) * PAGE_SIZE).map((item, index) => {

              if (inventory.type == "otherplayer" && item.metadata?.hidden ) {
                return
              }

              return  <InventorySlot
                key={`${inventory.type}-${inventory.id}-${item.slot}`}
                item={item}
                ref={index === (page + 1) * PAGE_SIZE - 1 ? ref : null}
                inventoryType={inventory.type}
                inventoryGroups={inventory.groups}
                inventoryId={inventory.id}
              />
            }
            )}
          </>
        </div>

        <div className="bottom-weight">

            {inventory.maxWeight && (
              <span className="weight-label">
                {weight / 1000}
              </span>
            )}

            <WeightBar percent={inventory.maxWeight ? (weight / inventory.maxWeight) * 100 : 0} />
            
            {inventory.maxWeight && (
              <span className="weight-label">
                {inventory.maxWeight / 1000}kg
              </span>
            )}
        </div>
      </div>
    </div>
  );
};

export default InventoryGrid;

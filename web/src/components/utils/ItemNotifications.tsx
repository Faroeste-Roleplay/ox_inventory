import React, { useContext } from 'react';
import { createPortal } from 'react-dom';
import { TransitionGroup } from 'react-transition-group';
import useNuiEvent from '../../hooks/useNuiEvent';
import useQueue from '../../hooks/useQueue';
import { Locale } from '../../store/locale';
import { getItemUrl } from '../../helpers';
import { SlotWithItem } from '../../typings';
import { Items } from '../../store/items';
import Fade from './transitions/Fade';

interface ItemNotificationProps {
  item: SlotWithItem;
  text: string;
  type: string;
}

export const ItemNotificationsContext = React.createContext<{
  add: (item: ItemNotificationProps) => void;
} | null>(null);

export const useItemNotifications = () => {
  const itemNotificationsContext = useContext(ItemNotificationsContext);
  if (!itemNotificationsContext) throw new Error(`ItemNotificationsContext undefined`);
  return itemNotificationsContext;
};

const ItemNotification = React.forwardRef(
  (props: { item: ItemNotificationProps; style?: React.CSSProperties }, ref: React.ForwardedRef<HTMLDivElement>) => {
    const slotItem = props.item.item;

    return (
      <div
        className="item-notification-item-box"
        ref={ref}
        style={{
          ...props.style,
        }}
      >

        <div className="item-slot-wrapper">
          <div className={`inventory-slot-label-box`}>

            <div className={`inventory-slot-label-text ${props.item.type}`}> {slotItem.metadata?.label || Items[slotItem.name]?.label} </div>

            <div className="item-notification-action-box">
              <p className={`${props.item.type}`} >{props.item.text}</p>
            </div>

          </div>

          <div className="item-slot-image" style={{
            backgroundImage: `url(${getItemUrl(slotItem) || 'none'}`,
          }} />
        </div>



      </div>
    );
  }
);

export const ItemNotificationsProvider = ({ children }: { children: React.ReactNode }) => {
  const queue = useQueue<{
    id: number;
    item: ItemNotificationProps;
    ref: React.RefObject<HTMLDivElement>;
  }>([
    // { id: 1, item: { item: { slot: 1, name: "money", count: 120, weight: 200 }, type: "ui_removed",  text: "ui_removed" }, ref: null },
    // { id: 1, item: { item: { slot: 1, name: "money", count: 120, weight: 200 }, text: "ui_removed" }, ref: null },
    // { id: 1, item: { item: { slot: 1, name: "money", count: 120, weight: 200 }, text: "ui_removed" }, ref: null },
    // { id: 1, item: { item: { slot: 1, name: "money", count: 120, weight: 200 }, text: "ui_removed" }, ref: null },
    // { id: 1, item: { item: { slot: 1, name: "money", count: 120, weight: 200 }, text: "ui_removed" }, ref: null }
  ]);

  const add = (item: ItemNotificationProps) => {
    const ref = React.createRef<HTMLDivElement>();
    const notification = { id: Date.now(), item, ref: ref };

    queue.add(notification);

    const timeout = setTimeout(() => {
      queue.remove();
      clearTimeout(timeout);
    }, 2500);
  };

  useNuiEvent<[item: SlotWithItem, text: string, count?: number]>('itemNotify', ([item, text, count]) => {
    const itemCount = item.name == "money" ? ((count ?? 1) / 100).toFixed(2) : count?.toLocaleString('en-us')
    add({ item: item, type: text, text: count ? `${Locale[text]} ${itemCount}x` : `${Locale[text]}` });
  });

  return (
    <ItemNotificationsContext.Provider value={{ add }}>
      {children}
      {createPortal(
        <TransitionGroup className="item-notification-container">
          {queue.values.map((notification, index) => (
            <Fade key={`item-notification-${index}`}>
              <ItemNotification item={notification.item} ref={notification.ref} />
            </Fade>
          ))}
        </TransitionGroup>,
        document.body
      )}
    </ItemNotificationsContext.Provider>
  );
};

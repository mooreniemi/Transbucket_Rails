import { Star } from 'lucide-react';
import styles from './ratingResults.module.css';

interface StatData {
    id: string;
    rating: number;
}

interface RatingResults {
    data: StatData[];
}

/* This is OK for POC, will likely have to adjust this for data shape */
export function RatingResults ({ data }: RatingResults) {
    const avgRating = data.length === 0
        ? 0
        : data.reduce((acc, procedure) => acc + procedure.rating, 0) / data.length;
    const gradient = avgRating / 5 * 100;
    const starArray = avgRating >= 1 ? Array.from({ length: Math.floor(avgRating)}, (_, index) => index + 1) : [];
    const distribution = data.length === 0
        ? new Map([[1, 0], [2, 0], [3, 0], [4, 0], [5, 0]])
        : data.reduce((acc, procedure) => {
            if (acc.has(procedure.rating)) {
                acc.set(procedure.rating, (acc.get(procedure.rating) || 0)+ 1)
            } else {
                acc.set(procedure.rating, 1);
            }
            return acc;
        }, new Map([[1, 0], [2, 0], [3, 0], [4, 0], [5, 0]]));

    return (
        <div className="min-w-2xs">
            <div>
                {starArray.map((star) => (
                    <Star key={star} className="fill-yellow-500 inline" size={32} strokeWidth={0} />
                ))}
                <Star fill="url(#grad1)" strokeWidth={0} size={32} className="inline">
                    <defs>
                        <linearGradient id="grad1" x1="0%" x2="100%" y1="0%" y2="0%">
                            <stop offset="0%" className={avgRating > 0 ? styles.linearGradientYellow : styles.linearGradientGrey} />
                            {avgRating > 0 && (
                                <stop offset={`${gradient}%`} className={styles.linearGradientYellow} />
                            )}
                            {avgRating !== 5 && (
                                <stop offset={`${gradient}%`} className={styles.linearGradientGrey} />
                            )}
                        </linearGradient>
                    </defs>
                </Star>
                <span className="font-semibold align-middle ml-2">{avgRating} / 5</span>
            </div>
            <div className="mt-4">
                {[1, 2, 3, 4, 5].map((value) => {
                    const count = distribution.get(value) ?? 0;
                    const width = data.length > 0 ? `${(count / data.length) * 100}%` : '0%';
                    return (
                        <div className={styles.plot} key={value}>
                            <span className="min-w-8">{value} <Star className="fill-yellow-500 inline" size={16} strokeWidth={0} /></span>
                            <div className="bg-black-300">
                                {count > 0 && (
                                    <a href="#" className="bg-blue-500 text-center block hover:ring-4 hover:ring-blue-500/50" style={{ width }}>{count}</a>
                                )}
                            </div>
                        </div>
                    );
                })}
            </div>
        </div>
    );
}

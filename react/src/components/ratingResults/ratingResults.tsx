import { Star } from 'lucide-react';
import styles from './ratingResults.module.css';

interface ProcedureData {
    id: string;
    rating: number;
}

interface RatingResults {
    data: ProcedureData[];
}

export function RatingResults ({ data }: RatingResults) {
    const avgRating = data.length === 0
        ? 0
        : data.reduce((acc, procedure) => acc + procedure.rating, 0) / data.length;
    const gradient = avgRating / 5 * 100;
    const starArray = avgRating >= 1 ? Array.from({ length: Math.floor(avgRating)}, (_, index) => index + 1) : [];
    return (
        <div>
            {starArray.map((star) => (
                <Star key={star} className={`${styles.fillYellow} inline`} size={32} strokeWidth={0} />
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
    );
}

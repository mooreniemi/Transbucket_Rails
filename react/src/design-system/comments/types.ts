interface User {
    id: string;
    name: string;
}

export interface Comment {
    id: string;
    text: string;
    user: User;
    date: Date;
}
